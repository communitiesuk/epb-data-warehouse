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

  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council_id: nil }
  end

  let(:domestic_search_result) do
    [{ "rrn": "0000-0000-0000-0000-0000", "address1" => "1 Some Street" }, { "rrn": "0000-0000-0000-0000-0001", "address1" => "2 Some Other Street" }]
  end

  let(:domestic_rr_search_result) do
    [{ "rrn": "0000-0000-0000-0000-0001", "indicative_cost" => "£15" }, { "rrn": "0000-0000-0000-0000-0001", "indicative_cost" => "£40000" }]
  end

  let(:expectation) do
    { domestic: domestic_search_result, domestic_rr: domestic_rr_search_result }
  end

  before do
    allow(search_gateway).to receive_messages(fetch: domestic_search_result, fetch_rr: domestic_rr_search_result)
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "passes the arguments to the gateway to fetch domestic data" do
    results = expectation.reject { |k| k == :domestic_rr }
    expect(use_case.execute(**search_arguments)).to eq results
    expect(search_gateway).to have_received(:fetch).with(search_arguments).exactly(1).times
    expect(search_gateway).to have_received(:fetch_rr).with(search_arguments).exactly(0).times
  end

  it "passes the same arguments to the gateway to additionally fetch domestic rr data" do
    search_arguments[:recommendations] = true
    expect(use_case.execute(**search_arguments)).to eq expectation
    expect(search_gateway).to have_received(:fetch).with(search_arguments).exactly(1).times
    expect(search_gateway).to have_received(:fetch_rr).with(search_arguments).exactly(1).times
  end

  context "when a council name is provided" do
    let(:args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", row_limit: 20, council_id: 1 }
    end

    before do
      args[:council] = "Hammersmith and Fulham"
      use_case.execute(**args)
    end

    it "passes the council id to the search" do
      expect(search_gateway).to have_received(:fetch).with(args).exactly(1).times
    end
  end

  context "when the dates are out of range" do
    it "raises an error" do
      search_arguments[:date_start] = "2023-12-24"
      search_arguments[:date_end] = "2023-12-23"
      search_arguments[:council] = nil
      expect { use_case.execute(**search_arguments) }.to raise_error(Boundary::InvalidDates)
    end
  end
end
