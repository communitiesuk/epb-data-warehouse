describe UseCase::ExportUserData do
  subject(:use_case) do
    described_class.new(domestic_search_gateway:, storage_gateway:, ons_gateway:)
  end

  let(:domestic_search_gateway) do
    instance_double(Gateway::DomesticSearchGateway)
  end

  let(:storage_gateway) do
    instance_double Gateway::StorageGateway
  end

  let(:ons_gateway) do
    instance_double Gateway::OnsPostcodeDirectoryNamesGateway
  end

  let(:domestic_search_result) do
    [
      {
        "rrn": "0000-0000-0000-0000-0000",
        "address_line_1": "Address line 1",
        "postcode": "SW1H 9AJ",
      },
      {
        "rrn": "0000-0000-0000-0000-0001",
        "address_line_1": "9 New Union Street",
        "postcode": "M4 6BW",
      },
    ]
  end

  let(:empty_domestic_search_result) do
    []
  end

  let(:expected_csv) do
    "rrn,address_line_1,postcode\n"\
    "0000-0000-0000-0000-0000,Address line 1,SW1H 9AJ\n"\
    "0000-0000-0000-0000-0001,9 New Union Street,M4 6BW\n"
  end

  context "when exporting domestic search data to S3" do
    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(storage_gateway).to receive(:write_file)
    end

    it "can call the use case" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.not_to raise_error
    end

    it "uploads search results to the S3 bucket" do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council")
      expect(domestic_search_gateway).to have_received(:fetch).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).with(file_name: "2023-12-01_2023-12-23_Birmingham-City-Council.csv", data: expected_csv)
    end

    it "uploads search results for all councils to the S3 bucket" do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23")
      expect(domestic_search_gateway).to have_received(:fetch).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).with(file_name: "2023-12-01_2023-12-23_All-Councils.csv", data: expected_csv)
    end
  end

  context "when there is a storage error" do
    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(storage_gateway).to receive(:write_file).and_raise Aws::S3::Errors::ServiceError.new(Seahorse::Client::RequestContext, "something has gone wrong")
    end

    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.to raise_error Aws::S3::Errors::ServiceError
    end
  end

  context "when there are no results" do
    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(domestic_search_gateway).to receive(:fetch).and_return empty_domestic_search_result
    end

    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.to raise_error Boundary::NoData
    end
  end
end
