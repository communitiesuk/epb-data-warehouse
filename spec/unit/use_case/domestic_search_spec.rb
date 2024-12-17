describe UseCase::DomesticSearch do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::DomesticSearchGateway)
  end
  let(:args) do
    { date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: nil }
  end

  let(:domestic_search_result) do
    [{ "rrn": "0000-0000-0000-0000-0000" }, { "rrn": "0000-0000-0000-0000-0001" }]
  end

  before do
    allow(gateway).to receive(:fetch).and_return domestic_search_result
  end

  it "can call the use case" do
    expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: nil) }.not_to raise_error
  end

  it "passed the argument to the gateway" do
    expect(use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: nil)).to eq domestic_search_result
    expect(gateway).to have_received(:fetch).with(args).exactly(1).times
  end

  context "when the dates are out of range" do
    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-24", date_end: "2023-12-23", row_limit: 20, council: nil) }.to raise_error(Boundary::InvalidDates)
    end
  end
end
