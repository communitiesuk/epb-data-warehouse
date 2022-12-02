require "mock_redis"

describe Gateway::ReportingRedisGateway do
  subject(:gateway) do
    described_class.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  let(:expected_data) do
    [{ month_year: "01-2022", num_epcs: 3 },
     { month_year: "02-2022", num_epcs: 2 },
     { month_year: "03-2022", num_epcs: 5 }]
  end

  after do
    redis.flushdb
  end

  describe "#save_report" do
    it "can call the method" do
      expect(gateway.save_report("key", "report")).to eq("OK")
    end

    it "saves the data to redis" do
      gateway.save_report("a", "b")
      expect(redis.get("a")).to eq("b")
    end

    it "saves data in the right shape" do
      gateway.save_report("heat_pump_report", expected_data.to_json)
      expect(redis.get("heat_pump_report")).to eq(expected_data.to_json)
    end

    #  create an array of hashes that looks like the data from the gateway
    # turn it into json
    # save it to redis
    # pull it out and make sure it looks the same

    #  in the use case have both gateways, pull it out and send it in
    # have a test for that

    #  ask douglas are we just setting these as keys, or do we do it in a more formalised way
  end
end
