describe UseCase::ExportUserData do
  subject(:use_case) do
    described_class.new(domestic_search_gateway:, multipart_storage_gateway:, ons_gateway:)
  end

  let(:domestic_search_gateway) do
    instance_double(Gateway::DomesticSearchGateway)
  end

  let(:multipart_storage_gateway) do
    instance_double Gateway::MultipartStorageGateway
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

  let(:expected_csv_headers) do
    "rrn,address_line_1,postcode\n"
  end

  let(:expected_csv_rows) do
    "0000-0000-0000-0000-0000,Address line 1,SW1H 9AJ\n"\
    "0000-0000-0000-0000-0001,9 New Union Street,M4 6BW\n"
  end

  let(:expected_csv_multiyear) do
    expected_csv_headers + expected_csv_rows * 6
  end
  let(:expected_csv) do
    expected_csv_headers + expected_csv_rows
  end

  let(:upload_id) do
    "UID-0000012345"
  end

  context "when exporting domestic search data to S3" do
    let(:multipart_upload_calls) do
      []
    end

    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(multipart_storage_gateway).to receive(:upload_part) do |args|
        multipart_upload_calls << args
        { etag: "ETAG-1234", part_number: args[:part_number] }
      end
      allow(multipart_storage_gateway).to receive(:create_upload).and_return(upload_id)
      allow(multipart_storage_gateway).to receive(:complete_upload)
      allow(multipart_storage_gateway).to receive(:buffer_size_check?)
    end

    it "can call the use case" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.not_to raise_error
    end

    it "uploads search results to the S3 bucket" do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council")
      expect(domestic_search_gateway).to have_received(:fetch).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:create_upload).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:upload_part).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:create_upload).with(file_name: "2023-12-01_2023-12-23_Birmingham-City-Council.csv")
      expect(multipart_storage_gateway).to have_received(:upload_part).with(file_name: "2023-12-01_2023-12-23_Birmingham-City-Council.csv", upload_id: upload_id, part_number: 1, data: expected_csv)
      expect(multipart_storage_gateway).to have_received(:complete_upload).with(file_name: "2023-12-01_2023-12-23_Birmingham-City-Council.csv", parts: [{ etag: "ETAG-1234", part_number: 1 }], upload_id: "UID-0000012345")
    end

    it "uploads search results for all councils to the S3 bucket" do
      use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23")
      expect(domestic_search_gateway).to have_received(:fetch).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:create_upload).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:upload_part).exactly(1).times
      expect(multipart_storage_gateway).to have_received(:create_upload).with(file_name: "2023-12-01_2023-12-23_All-Councils.csv")
      expect(multipart_storage_gateway).to have_received(:upload_part).with(file_name: "2023-12-01_2023-12-23_All-Councils.csv", upload_id: upload_id, part_number: 1, data: expected_csv)
      expect(multipart_storage_gateway).to have_received(:complete_upload).with(file_name: "2023-12-01_2023-12-23_All-Councils.csv", parts: [{ etag: "ETAG-1234", part_number: 1 }], upload_id: "UID-0000012345")
    end

    it "uploads search results in parts for multi-year searches" do
      allow(multipart_storage_gateway).to receive(:buffer_size_check?).and_return(true)

      expected_domestic_search_calls = [
        { date_start: "2010-02-07", date_end: "2010-12-31", council_id: nil },
        { date_start: "2011-01-01", date_end: "2011-12-31", council_id: nil },
        { date_start: "2012-01-01", date_end: "2012-12-31", council_id: nil },
        { date_start: "2013-01-01", date_end: "2013-12-31", council_id: nil },
        { date_start: "2014-01-01", date_end: "2014-12-31", council_id: nil },
        { date_start: "2015-01-01", date_end: "2015-09-21", council_id: nil },
      ]

      expected_multipart_storage_calls = [
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 1, data: expected_csv },
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 2, data: expected_csv_rows },
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 3, data: expected_csv_rows },
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 4, data: expected_csv_rows },
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 5, data: expected_csv_rows },
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 6, data: expected_csv_rows },
      ]

      expected_multipart_parts = [
        { etag: "ETAG-1234", part_number: 1 },
        { etag: "ETAG-1234", part_number: 2 },
        { etag: "ETAG-1234", part_number: 3 },
        { etag: "ETAG-1234", part_number: 4 },
        { etag: "ETAG-1234", part_number: 5 },
        { etag: "ETAG-1234", part_number: 6 },
      ]

      use_case.execute(date_start: "2010-02-07", date_end: "2015-09-21")

      expected_domestic_search_calls.each do |expected_call|
        expect(domestic_search_gateway).to have_received(:fetch).with(expected_call).ordered
      end

      expect(multipart_upload_calls).to eq(expected_multipart_storage_calls)
      expect(multipart_storage_gateway).to have_received(:complete_upload).with(file_name: "2010-02-07_2015-09-21_All-Councils.csv", parts: expected_multipart_parts, upload_id: "UID-0000012345")
    end

    it "buffers uploads when results are lower than 5MB" do
      expected_multipart_storage_calls = [
        { file_name: "2010-02-07_2015-09-21_All-Councils.csv", upload_id: upload_id, part_number: 1, data: expected_csv_multiyear },
      ]

      expected_multipart_parts = [
        { etag: "ETAG-1234", part_number: 1 },
      ]

      use_case.execute(date_start: "2010-02-07", date_end: "2015-09-21")

      expect(multipart_upload_calls).to eq(expected_multipart_storage_calls)
      expect(multipart_storage_gateway).to have_received(:complete_upload).with(file_name: "2010-02-07_2015-09-21_All-Councils.csv", parts: expected_multipart_parts, upload_id: "UID-0000012345")
    end
  end

  context "when there is a storage error" do
    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(domestic_search_gateway).to receive(:fetch).and_return domestic_search_result
      allow(multipart_storage_gateway).to receive(:create_upload)
      allow(multipart_storage_gateway).to receive(:upload_part).and_raise Aws::S3::Errors::NoSuchUpload.new(Seahorse::Client::RequestContext, "something has gone wrong")
    end

    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.to raise_error Aws::S3::Errors::ServiceError
    end
  end

  context "when there are no results" do
    before do
      allow(ons_gateway).to receive(:fetch_council_id).and_return("12345")
      allow(multipart_storage_gateway).to receive(:create_upload).and_return(upload_id)
      allow(domestic_search_gateway).to receive(:fetch).and_return empty_domestic_search_result
    end

    it "raises an error" do
      expect { use_case.execute(date_start: "2023-12-01", date_end: "2023-12-23", council: "Birmingham City Council") }.to raise_error Boundary::NoData
    end
  end
end
