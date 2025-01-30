describe UseCase::ExportUserData do
  subject(:use_case) do
    described_class.new(domestic_search_gateway:, storage_gateway:)
  end

  let(:domestic_search_gateway) do
    instance_double(Gateway::DomesticSearchGateway)
  end

  let(:storage_gateway) do
    instance_double Gateway::StorageGateway
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

  let(:expected_csv) do
    "rrn,address_line_1,postcode\n"\
    "0000-0000-0000-0000-0000,Address line 1,SW1H 9AJ\n"\
    "0000-0000-0000-0000-0001,9 New Union Street,M4 6BW\n"
  end

  context "when exporting domestic search data to S3" do
    before do
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(storage_gateway).to receive(:write_file)
    end

    it "can call the use case" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council_id: 1234) }.not_to raise_error
    end

    it "converts search results into csv" do
      expect(use_case.convert_to_csv(data: domestic_search_result)).to eq expected_csv
    end

    it "uploads search results to the S3 bucket" do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council_id: 1234)
      expect(domestic_search_gateway).to have_received(:fetch).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).exactly(1).times
      expect(storage_gateway).to have_received(:write_file).with(file_name: "2023-12-01_2023-12-23_1234.csv", data: expected_csv)
    end
  end

  context "when there is a storage error" do
    before do
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(storage_gateway).to receive(:write_file).and_raise Aws::S3::Errors::ServiceError.new(Seahorse::Client::RequestContext, "something has gone wrong")
    end

    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council_id: 1234) }.to raise_error Aws::S3::Errors::ServiceError
    end
  end
end
