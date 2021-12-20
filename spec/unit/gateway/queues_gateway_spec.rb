require "securerandom"

describe Gateway::QueuesGateway do
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

  context "when processing a queue of IDs" do
    it "can consume the IDs back out of the queue when pushed on in one push" do
      gateway.push_to_queue(:assessments, ids)
      expect(gateway.consume_queue(:assessments)).to eq ids
    end

    it "can consume the IDs back out of the queue when pushed onto the queue one by one" do
      ids.each { |id| gateway.push_to_queue(:assessments, id) }
      expect(gateway.consume_queue(:assessments)).to eq ids
    end

    it "leaves an empty queue once a relatively small queue has been consumed" do
      gateway.push_to_queue(:assessments, ids)
      gateway.consume_queue(:assessments)

      expect(gateway.consume_queue(:assessments)).to eq []
    end

    it "raises an error for an invalid queue name" do
      expect { gateway.push_to_queue(:none_existing_queue, ids) }.to raise_error(
        Gateway::QueueNames::InvalidNameError,
      )
      expect { gateway.consume_queue(:none_existing_queue) }.to raise_error(
        Gateway::QueueNames::InvalidNameError,
      )
    end

    context "when queue is populated with more IDs than the default consume count of 50" do
      before do
        gateway.push_to_queue(:assessments, (1..75).collect { |_| SecureRandom.uuid })
      end

      it "consumes the default consume count of 50, leaving the expected remainder on the queue" do
        consumed = gateway.consume_queue(:assessments).length
        remainder = redis.llen("assessments").to_i
        expect([consumed, remainder]).to eq [50, 25]
      end
    end
  end
end
