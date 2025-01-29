describe UseCase::DomesticSearch do
  subject(:use_case) do
    described_class.new(search_gateway:, ons_gateway:)
  end

  let(:ons_gateway) do
    instance_double(Gateway::OnsPostcodeDirectoryNamesGateway)
  end

  let(:search_gateway) do
    instance_double(Gateway::DomesticSearchGateway)
  end

  let(:args) do
    { date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council_id: nil }
  end

  let(:domestic_search_result) do
    [{ "rrn": "0000-0000-0000-0000-0000" }, { "rrn": "0000-0000-0000-0000-0001" }]
  end

  before do
    allow(search_gateway).to receive(:fetch).and_return domestic_search_result
    allow(ons_gateway).to receive(:fetch_council_id).and_return 1
  end

  it "can call the use case" do
    expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: nil) }.not_to raise_error
  end

  it "passed the argument to the search gateway" do
    expect(use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: nil)).to eq domestic_search_result
    expect(search_gateway).to have_received(:fetch).with(args).exactly(1).times
  end

  context "when a council name is provided" do
    let(:args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council_id: 1 }
    end

    before do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council: "Hammersmith and Fulham")
    end

    it "passes the council id to the search" do
      expect(search_gateway).to have_received(:fetch).with(args).exactly(1).times
    end
  end

  context "when the dates are out of range" do
    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-24", date_end: "2023-12-23", row_limit: 20, council: nil) }.to raise_error(Boundary::InvalidDates)
    end
  end
end
