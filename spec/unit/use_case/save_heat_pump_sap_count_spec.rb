describe UseCase::SaveHeatPumpSapCount do
  subject(:use_case) { described_class.new(reporting_redis_gateway:, reporting_gateway:) }

  let(:reporting_gateway) { instance_double(Gateway::ReportingGateway) }
  let(:reporting_redis_gateway) { instance_double(Gateway::ReportingRedisGateway) }
  let(:report_name) { "heat_pump_count_for_sap" }

  let(:expected_data) do
    [{ month_year: "01-2022", num_epcs: 3 },
     { month_year: "02-2022", num_epcs: 2 },
     { month_year: "03-2022", num_epcs: 5 }]
  end

  before do
    allow(reporting_gateway).to receive(:heat_pump_count_for_sap).and_return(expected_data)
    allow(reporting_redis_gateway).to receive(:save_report)
  end

  context "when invoking the use case to save a report to redis" do
    it "can call the use case" do
      expect { use_case.execute }.not_to raise_error
    end

    it "the reporting gateway receives the report method" do
      use_case.execute
      expect(reporting_gateway).to have_received(:heat_pump_count_for_sap)
    end

    it "the reporting gateway passes the returned data to the reporting redis gateway" do
      use_case.execute
      expect(reporting_redis_gateway).to have_received(:save_report).with(report_name, expected_data)
    end
  end

  context "when invoking the use case with no data" do
    it "raises an no data error" do
      allow(reporting_gateway).to receive(:heat_pump_count_for_sap).and_return([])
      expect { use_case.execute }.to raise_error(Boundary::NoData)
    end
  end
end
