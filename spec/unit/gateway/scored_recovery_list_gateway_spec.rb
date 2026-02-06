describe Gateway::ScoredRecoveryListGateway do
  subject(:gateway) do
    described_class.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  let(:payloads) do
    %w[0000-0000-0000-0000-0001:1000000001 0000-0000-0000-0000-0002:1000000002]
  end

  let(:queue) do
    "matched_address_update"
  end

  let(:recovery_queue) { "#{queue}_recovery" }
  let(:scored_recovery_queue) { "#{queue}_recovery_scored" }

  after do
    redis.flushdb
  end

  describe "#register_assessments" do
    context "when registering payloads to the queue" do
      before do
        gateway.register_assessments(*payloads, queue:)
      end

      it "adds the payload to the recovery queue" do
        expect(redis.hkeys(recovery_queue)).to eq payloads
      end

      it "adds the payload into the scored-recovery queue" do
        expect(redis.zrangebyscore(scored_recovery_queue, "-inf", "+inf")).to eq payloads
      end
    end

    context "when registering payloads to a queue that is unknown" do
      it "raises an invalid name error" do
        expect { gateway.register_assessments("0000-0000-0000-0000-0000", queue: :unknown) }.to raise_error Gateway::QueueNames::InvalidNameError
      end
    end

    context "when registering an empty list of payloads" do
      let(:stub_redis) do
        redis = instance_double Redis
        allow(redis).to receive(:hset)
        allow(redis).to receive(:zadd)
        redis
      end

      before do
        described_class.new(redis_client: stub_redis).register_assessments(queue:)
      end

      it "does not call down onto the redis store" do
        expect(stub_redis).not_to have_received :hset
        expect(stub_redis).not_to have_received :zadd
      end
    end
  end

  describe "#clear_assessments" do
    context "when clearing a payload from the queue" do
      before do
        gateway.register_assessments(*payloads, queue:)
        gateway.clear_assessment(payload: "0000-0000-0000-0000-0001:1000000001", queue:)
      end

      it "removes the payload from the recovery queue" do
        expect(redis.hkeys(recovery_queue)).to eq ["0000-0000-0000-0000-0002:1000000002"]
      end

      it "removes the payload from the scored-recovery queue" do
        expect(redis.zrangebyscore(scored_recovery_queue, "-inf", "+inf")).to eq ["0000-0000-0000-0000-0002:1000000002"]
      end
    end
  end

  describe "#assessments" do
    let(:assessments_redis) do
      AssessmentsMockRedis.new
    end

    let(:gateway_for_assessments) do
      described_class.new redis_client: assessments_redis
    end

    context "when assessments are fetched but one is already being processed" do
      before do
        gateway_for_assessments.register_assessments(*payloads, queue: queue)
        assessments_redis.zadd(scored_recovery_queue, Time.now.to_f + 90, "0000-0000-0000-0000-0002:1000000002")
      end

      it "only returns the assessments not already being processed" do
        expect(gateway_for_assessments.assessments(queue:)).to eq ["0000-0000-0000-0000-0001:1000000001"]
      end
    end

    context "when assessments are fetched" do
      before do
        gateway_for_assessments.register_assessments(*payloads, queue: queue)
      end

      it "returns all the assessments" do
        expect(gateway_for_assessments.assessments(queue:)).to eq payloads
      end
    end

    context "when there are no assessments remaining in the recovery queue" do
      it "returns no assessment IDs" do
        expect(gateway_for_assessments.assessments(queue:)).to eq []
      end
    end

    context "when executing the function" do
      let(:expected_eval_call) do
        [
          "local queue_key = KEYS[1]\nlocal now = tonumber(ARGV[1])\nlocal timeout = tonumber(ARGV[2])\nlocal limit = tonumber(ARGV[3])\nlocal next_visible_at = now + timeout\n\nlocal items = redis.call('ZRANGEBYSCORE', queue_key, '-inf', now, 'LIMIT', 0, limit)\n\nif #items > 0 then\n  local args = {}\n  for i, item in ipairs(items) do\n    table.insert(args, next_visible_at)\n    table.insert(args, item)\n  end\n  redis.call('ZADD', queue_key, unpack(args))\nend\nreturn items\n",
          { argv: [1_756_986_000.0, 120, 50],
            keys: %w[matched_address_update_recovery_scored] },
        ]
      end
      let(:assessments_redis) do
        instance_double AssessmentsMockRedis
      end

      let(:gateway_for_assessments) do
        described_class.new redis_client: assessments_redis
      end

      before do
        allow(assessments_redis).to receive(:eval)
      end

      it "calls eval with the expected script and arguments" do
        Timecop.freeze(2025, 9, 4, 12, 40, 0) do
          gateway_for_assessments.assessments(queue:)
        end
        expect(assessments_redis).to have_received(:eval).with(*expected_eval_call)
      end
    end
  end

  describe "#register_attempt" do
    let(:register_attempt_redis) do
      RegisterAttemptMockRedis.new
    end

    let(:gateway_for_register_attempt) do
      described_class.new redis_client: register_attempt_redis
    end

    context "when running the redis script in ruby" do
      before do
        Timecop.freeze(2025, 9, 4, 12, 40, 0) do
          gateway_for_register_attempt.register_assessments(*payloads, queue: queue, retries: 50)
          payloads.each do |payload|
            register_attempt_redis.zadd(scored_recovery_queue, Time.now.to_f + 100, payload)
          end

          gateway_for_register_attempt.register_attempt(payload: "0000-0000-0000-0000-0001:1000000001", queue:)
        end
      end

      context "when registering an attempt" do
        it "sets the score to now" do
          expect(register_attempt_redis.zscore(scored_recovery_queue, "0000-0000-0000-0000-0001:1000000001")).to eq(Time.new(2025, 9, 4, 12, 40, 0).to_f)
        end

        it "decreases the number of remaining attempts" do
          expect(register_attempt_redis.hget(recovery_queue, "0000-0000-0000-0000-0001:1000000001").to_i).to eq(49)
        end
      end

      context "when registering the last attempt" do
        before do
          register_attempt_redis.hset(recovery_queue, "0000-0000-0000-0000-0002:1000000002", 1)
          gateway_for_register_attempt.register_attempt(payload: "0000-0000-0000-0000-0002:1000000002", queue:)
        end

        it "removes the payload from the attempts queue" do
          expect(register_attempt_redis.hget(recovery_queue, "0000-0000-0000-0000-0002:1000000002")).to eq(nil)
        end

        it "removes the payload from the scored queue" do
          expect(register_attempt_redis.zscore(scored_recovery_queue, "0000-0000-0000-0000-0002:1000000002")).to eq(nil)
        end
      end
    end

    context "when executing the function" do
      let(:expected_eval_call) do
        [
          "local hash_key = KEYS[1]\nlocal zset_key = KEYS[2]\nlocal payload = ARGV[1]\nlocal now = tonumber(ARGV[2])\n\nlocal attempts = redis.call('HGET', hash_key, payload)\n\nif not attempts or tonumber(attempts) <= 1 then\n  redis.call('HDEL', hash_key, payload)\n  redis.call('ZREM', zset_key, payload)\nelse\n  redis.call('HINCRBY', hash_key, payload, -1)\n  redis.call('ZADD', zset_key, now, payload)\nend\n",
          { argv: ["0000-0000-0000-0000-0002:1000000002", 1_756_986_000.0],
            keys: %w[matched_address_update_recovery matched_address_update_recovery_scored] },
        ]
      end
      let(:register_attempt_redis) do
        instance_double RegisterAttemptMockRedis
      end

      let(:gateway_for_register_attempt) do
        described_class.new redis_client: register_attempt_redis
      end

      before do
        allow(register_attempt_redis).to receive(:eval)
      end

      it "calls eval with the expected script and arguments" do
        Timecop.freeze(2025, 9, 4, 12, 40, 0) do
          gateway_for_register_attempt.register_attempt(payload: "0000-0000-0000-0000-0002:1000000002", queue:)
        end
        expect(register_attempt_redis).to have_received(:eval).with(*expected_eval_call)
      end
    end
  end

  describe "#retries_left" do
    payload = "0000-0000-0000-0000-0003:1000000003"

    context "when the assessment exists in the queue" do
      retries = 42

      before do
        gateway.register_assessments(payload, queue: :assessments, retries:)
      end

      it "gives the correct count of retries left" do
        expect(gateway.retries_left(payload: payload, queue: :assessments)).to eq retries
      end
    end

    context "when the assessment does not exist in the queue" do
      it "gives a count of zero retries left" do
        expect(gateway.retries_left(payload: payload, queue: :assessments)).to eq 0
      end
    end
  end
end

class AssessmentsMockRedis < MockRedis
  # We define the method directly, bypassing RSpec stubs and the Kernel#eval collision
  def eval(_script, keys: [], argv: [], **_options)
    # 1. Parse args just like the Lua script
    queue_key = keys[0]
    now = argv[0].to_f
    timeout = argv[1].to_f
    limit = argv[2].to_i

    # 2. Run the Ruby "Shim" logic (calling methods on 'self')

    # Logic: ZRANGEBYSCORE (Find items available now)
    items = zrangebyscore(queue_key, "-inf", now, limit: [0, limit])

    # Logic: ZADD (Lock items for the future)
    if items.any?
      next_visible_at = now + timeout
      updates = items.map { |item| [next_visible_at, item] }
      zadd(queue_key, updates)
    end
    items
  end
end

class RegisterAttemptMockRedis < MockRedis
  def eval(_script, keys: [], argv: [], **_options)
    hash_key = keys[0]
    zset_key = keys[1]
    payload = argv[0]
    now = argv[1].to_f

    attempts = hget(hash_key, payload).to_i

    if attempts <= 1
      hdel(hash_key, payload)
      zrem(zset_key, payload)
    else
      hincrby(hash_key, payload, -1)
      zadd(zset_key, now, payload)
    end
  end
end
