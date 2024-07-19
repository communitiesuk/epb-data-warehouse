describe Gateway::RecoveryListGateway do
  subject(:gateway) do
    described_class.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  let(:ids) do
    %w[9999-0000-0000-0000-5444 9999-0000-0000-0000-4444]
  end

  after do
    redis.flushdb
  end

  context "when no assessments have been added to the recovery list" do
    it "returns no assessment IDs when calling #assessments" do
      expect(gateway.assessments(queue: :assessments)).to eq []
    end
  end

  context "when assessments have been registered" do
    before do
      gateway.register_assessments(*ids, queue: :assessments)
    end

    it "reads the assessments back out of the list" do
      expect(gateway.assessments(queue: :assessments).sort).to eq ids.sort
    end

    context "when an assessment has been removed" do
      removed_id = "9999-0000-0000-0000-4444"

      before do
        gateway.clear_assessment(payload: removed_id, queue: :assessments)
      end

      it "has removed the assessment" do
        expected_assessments_without_removed = ids.reject { |id| id == removed_id }
        expect(gateway.assessments(queue: :assessments).sort).to eq expected_assessments_without_removed.sort
      end
    end
  end

  # NB. asserting here that the Lua script is called against a mock Redis client object as MockRedis does not support EVAL
  context "when registering attempts to recover" do
    let(:gateway_for_attempts) do
      described_class.new redis_client: stub_redis
    end

    let(:stub_redis) do
      redis = instance_double Redis
      allow(redis).to receive(:eval)
      redis
    end

    it "calls the lua script against the redis instance" do
      attempted_assessment = "1234-5678-9012-3456-7890"
      lua = "local assessments = redis.call('HGET', KEYS[1], ARGV[1]); if not assessments or tonumber(assessments) <= 1 then redis.call('HDEL', KEYS[1], ARGV[1]) else redis.call('HINCRBY', KEYS[1], ARGV[1], -1) end"
      gateway_for_attempts.register_attempt payload: attempted_assessment, queue: :assessments

      expect(stub_redis).to have_received(:eval).with(lua, keys: %w[assessments_recovery], argv: [attempted_assessment])
    end
  end

  context "when getting the number of retries left" do
    assessment_id = "0123-4567-8901-2345-6789"

    context "when the assessment exists in the queue" do
      retries = 42

      before do
        gateway.register_assessments(assessment_id, queue: :assessments, retries:)
      end

      it "gives the correct count of retries left" do
        expect(gateway.retries_left(payload: assessment_id, queue: :assessments)).to eq retries
      end
    end

    context "when the assessment does not exist in the queue" do
      it "gives a count of zero retries left" do
        expect(gateway.retries_left(payload: assessment_id, queue: :assessments)).to eq 0
      end
    end
  end

  context "when referencing a queue that is unknown" do
    it "raises an invalid name error" do
      expect { gateway.register_assessments("0000-0000-0000-0000-0000", queue: :unknown) }.to raise_error Gateway::QueueNames::InvalidNameError
    end
  end

  context "when registering an empty list of assessments" do
    let(:stub_redis) do
      redis = instance_double Redis
      allow(redis).to receive(:hset)
      redis
    end

    before do
      described_class.new(redis_client: stub_redis).register_assessments queue: :assessments
    end

    it "does not call down onto the redis store" do
      expect(stub_redis).not_to have_received :hset
    end
  end
end
