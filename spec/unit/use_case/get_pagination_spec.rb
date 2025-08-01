describe UseCase::GetPagination do
  subject(:use_case) do
    described_class.new(search_gateway:)
  end

  let(:search_gateway) do
    instance_double(Gateway::AssessmentSearchGateway)
  end

  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 3 }
  end

  let(:expected_return_hash) do
    { total_records: 60_000, current_page: 3, total_pages: 12, next_page: 4, prev_page: 2 }
  end

  before do
    allow(search_gateway).to receive_messages(count: 60_000)
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "returns a hash" do
    expect(use_case.execute(**search_arguments)).to be_a(Hash)
  end

  it "passes the arguments to the gateway to count domestic data" do
    use_case.execute(**search_arguments)
    expect(search_gateway).to have_received(:count).with(search_arguments).exactly(1).times
  end

  it "returns the expected hash" do
    expect(use_case.execute(**search_arguments)).to eq expected_return_hash
  end

  context "when current page is 1" do
    let(:current_page_1_args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 1 }
    end

    before do
      allow(search_gateway).to receive_messages(count: 20)
    end

    it "returns nil for previous page" do
      expect(use_case.execute(**current_page_1_args)[:prev_page]).to be_nil
    end

    it "returns nil for next page when total records is below threshold" do
      expect(use_case.execute(**current_page_1_args)[:next_page]).to be_nil
    end
  end

  context "when total records is less than 5000" do
    before do
      allow(search_gateway).to receive_messages(count: 1222)
    end

    let(:search_arguments) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 1 }
    end

    let(:expected_return_hash) do
      { total_records: 1222, current_page: 1, total_pages: 1, next_page: nil, prev_page: nil }
    end

    it "returns total pages of 1" do
      result = use_case.execute(**search_arguments)
      expect(result).to eq expected_return_hash
    end
  end

  context "when total record count is not divisible by number of rows" do
    before do
      allow(search_gateway).to receive_messages(count: 71_882)
    end

    let(:search_arguments) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 3 }
    end

    let(:expected_return_hash) do
      { total_records: 71_882, current_page: 3, total_pages: 15, next_page: 4, prev_page: 2 }
    end

    it "returns correct total pages value" do
      result = use_case.execute(**search_arguments)
      expect(result).to eq expected_return_hash
    end
  end
end
