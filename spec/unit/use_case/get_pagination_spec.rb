describe UseCase::GetPagination do
  subject(:use_case) do
    described_class.new(assessment_search_gateway:)
  end

  let(:assessment_search_gateway) do
    instance_double(Gateway::AssessmentSearchGateway)
  end

  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 3 }
  end

  let(:expected_return_hash) do
    { total_records: 60_000, current_page: 3, total_pages: 12, next_page: 4, prev_page: 2 }
  end

  before do
    allow(assessment_search_gateway).to receive_messages(count: 60_000)
  end

  it "can call the use case" do
    expect { use_case.execute(**search_arguments) }.not_to raise_error
  end

  it "returns a hash" do
    expect(use_case.execute(**search_arguments)).to be_a(Hash)
  end

  it "passes the arguments to the gateway to count domestic data" do
    use_case.execute(**search_arguments)
    expect(assessment_search_gateway).to have_received(:count).with(search_arguments).exactly(1).times
  end

  it "returns the expected hash" do
    expect(use_case.execute(**search_arguments)).to eq expected_return_hash
  end

  context "when current page is 1" do
    let(:current_page_1_args) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 1 }
    end

    before do
      allow(assessment_search_gateway).to receive_messages(count: 20)
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
      allow(assessment_search_gateway).to receive_messages(count: 1222)
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

  context "when the row_limit is 100" do
    before do
      allow(assessment_search_gateway).to receive_messages(count: 1222)
      use_case.row_limit = 100
    end

    let(:search_arguments) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 1 }
    end

    let(:expected_return_hash) do
      { total_records: 1222, current_page: 1, total_pages: 13, next_page: 2, prev_page: nil }
    end

    it "returns total pages of 1" do
      result = use_case.execute(**search_arguments)
      expect(result).to eq expected_return_hash
    end
  end

  context "when total record count is not divisible by number of rows" do
    before do
      allow(assessment_search_gateway).to receive_messages(count: 71_882)
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

  context "when current page is out of range" do
    before do
      allow(assessment_search_gateway).to receive_messages(count: 390)
    end

    it "raises an OutOfPaginationRangeError when current page is 0" do
      search_args_page_0 = { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 0 }
      expect { use_case.execute(**search_args_page_0) }.to raise_error(Errors::OutOfPaginationRangeError)
    end

    it "raises an OutOfPaginationRangeError when current page is greater than 1" do
      search_args_page_2 = { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 2 }
      expect { use_case.execute(**search_args_page_2) }.to raise_error(Errors::OutOfPaginationRangeError)
    end
  end

  context "when total records is 0" do
    before do
      allow(assessment_search_gateway).to receive_messages(count: 0)
    end

    it "raises an NoData error" do
      expect { use_case.execute(**search_arguments) }.to raise_error(Boundary::NoData)
    end
  end

  context "when row_limit is smaller than the record set" do
    before do
      allow(assessment_search_gateway).to receive_messages(count: 100)
      use_case.row_limit = 5000
    end

    let(:expected_return_hash) do
      { total_records: 100, current_page: 1, total_pages: 1, next_page: nil, prev_page: nil }
    end

    let(:search_arguments) do
      { date_start: "2023-12-01", date_end: "2023-12-23", current_page: 1 }
    end

    it "returns correct total pages value" do
      result = use_case.execute(**search_arguments)
      expect(result).to eq expected_return_hash
    end
  end
end
