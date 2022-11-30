describe UseCase::FetchHeatPumpSapCount do
  let(:reporting_gateway) do
    instance_double(Gateway::ReportingGateway)
  end

  let!(:use_case) do
    described_class.new reporting_gateway
  end

  before do
    allow(reporting_gateway).to receive(:heat_pump_count_for_sap)
  end

  it "call the use case without without error" do
    use_case.execute
    expect(reporting_gateway).to have_received(:heat_pump_count_for_sap).exactly(1).times
  end
end
