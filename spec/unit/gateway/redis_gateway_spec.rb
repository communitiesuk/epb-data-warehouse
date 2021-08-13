require "securerandom"

describe Gateway::RedisGateway do
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
    it "can consume the first ID on the queue when pushed in one go" do
      gateway.push_to_queue "assessments", ids
      expect(gateway.consume_queue("assessments")).to eq "9999-0000-0000-0000-5444"
    end

    it "can consume the first ID out of the queue when pushed onto the queue one by one" do
      ids.each { |id| gateway.push_to_queue "assessments", id }
      expect(gateway.consume_queue("assessments")).to eq "9999-0000-0000-0000-5444"
    end

    it "leaves an empty queue once the last element has been consumed" do
      gateway.push_to_queue "assessments", ids
      gateway.consume_queue("assessments")
      gateway.consume_queue("assessments")
      expect(gateway.consume_queue("assessments")).to be_nil
    end
  end
end
