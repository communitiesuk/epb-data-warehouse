describe UseCase::CountDomesticCertificates do
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
    { date_start: "2023-12-01", date_end: "2023-12-23", council_id: nil }
  end

  # let(:count_domestic_result) do
  #   20
  # end

  let(:expectation) do
    20
  end

  before do
    allow(search_gateway).to receive_messages(count: 20)
    allow(ons_gateway).to receive(:fetch_council_id).and_return 1
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "passes the arguments to the gateway to count domestic data" do
    expect(use_case.execute(**search_arguments)).to eq expectation
    expect(search_gateway).to have_received(:count).with(search_arguments).exactly(1).times
  end

  context "when a council name is provided" do
    let(:args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", council_id: 1 }
    end

    before do
      args[:council] = "Hammersmith and Fulham"
      use_case.execute(**args)
    end

    it "passes the council id to the search" do
      expect(search_gateway).to have_received(:count).with(args).exactly(1).times
    end
  end
end
