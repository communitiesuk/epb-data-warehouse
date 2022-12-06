# frozen_string_literal: true

require "mock_redis"

describe Gateway::ReportTriggersGateway do
  subject(:gateway) do
    described_class.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  after do
    redis.flushdb
  end

  describe "#triggers" do
    context "when the triggers are empty/ not set" do
      it "returns an empty list of triggers" do
        expect(gateway.triggers).to eq []
      end
    end

    context "when there are some triggers" do
      let(:report_triggers) { ["loud noises", "quiet shufflings"] }

      before do
        redis.sadd("report_triggers", report_triggers)
      end

      it "returns the triggers" do
        expect(gateway.triggers).to eq report_triggers.map(&:to_sym)
      end
    end
  end

  describe "#remove_trigger" do
    context "when trying to remove a nonexistent trigger" do
      it "does not change the count of the report_triggers set" do
        first_count = redis.scard "report_triggers"
        gateway.remove_trigger :unknown_trigger
        expect(redis.scard("report_triggers")).to eq first_count
      end
    end

    context "when trying to remove a trigger that is present" do
      let(:report_triggers) { ["loud noises", "quiet shufflings"] }

      before do
        redis.sadd("report_triggers", report_triggers)
        gateway.remove_trigger "loud noises"
      end

      it "only contains members excluding the one removed" do
        expect(redis.smembers("report_triggers")).to eq ["quiet shufflings"]
      end
    end
  end
end
