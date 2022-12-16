require "mock_redis"

describe Gateway::ReportingRedisGateway do
  subject(:gateway) do
    described_class.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  let(:expected_data) do
    [{ month_year: "01-2022", num_epcs: 3 },
     { month_year: "02-2022", num_epcs: 2 },
     { month_year: "03-2022", num_epcs: 5 },
     { month_year: "04-2022", num_epcs: 0 },
     { month_year: "05-2022", num_epcs: 0 },
     { month_year: "06-2022", num_epcs: 0 },
     { month_year: "07-2022", num_epcs: 0 },
     { month_year: "08-2022", num_epcs: 0 },
     { month_year: "09-2022", num_epcs: 0 },
     { month_year: "10-2022", num_epcs: 0 },
     { month_year: "11-2022", num_epcs: 0 },
     { month_year: "12-2022", num_epcs: 0 }]
  end

  after do
    redis.flushdb
  end

  before(:all) do
    Timecop.freeze Time.new(2022, 11, 30, 4, 30, 0, "+03:00")
  end

  after(:all) do
    Timecop.return
  end

  describe "#save_report" do
    let(:saved_data) do
      JSON.parse(redis.hget(:reports, :heat_pump_report))
    end

    before do
      gateway.save_report(:heat_pump_report, expected_data.to_json)
    end

    it "can call the method" do
      expect(gateway.save_report("key", "report")).to eq(1)
    end

    it "saves the queried data to redis" do
      expect(saved_data).to be_a Hash
    end

    it "saves the query results in a key called data" do
      expect(saved_data["data"]).to eq(expected_data.to_json)
    end

    it "saves the data with a key for the date now" do
      expect(saved_data["date_created"]).to eq "2022-11-30T01:30:00Z"
    end
  end
end
