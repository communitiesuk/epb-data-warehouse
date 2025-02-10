require_relative "../../shared_context/shared_s3_stubs"

describe Gateway::MultipartStorageGateway do
  context "when storage is initialised" do
    subject(:storage_gateway) do
      described_class.new(
        bucket_name: "my-bucket",
        stub_responses: true,
      )
    end

    let(:fake_s3) { {} }
    let(:fake_multipart_s3) { [] }

    context "when doing multipart uploads" do
      include_context "when stubbing multipart uploads to S3"
      before do
        stub_file_response(storage_gateway.client)
        storage_gateway.client.create_bucket(bucket: "my-bucket")
      end

      it "catches and raises an error if upload_id was not created" do
        expect { storage_gateway.upload_part(file_name: "test", upload_id: "fake_id", part_number: 1, data: "Hello!") }.to raise_error Aws::S3::Errors::NoSuchUpload
      end

      it "successfully upload parts" do
        upload_id = storage_gateway.create_upload(file_name: "test")
        response = storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 1, data: "Hello!")
        expect(response[:etag]).not_to be_nil
      end

      it "successfully completes upload parts" do
        upload_id = storage_gateway.create_upload(file_name: "test")
        parts = []
        parts << storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 1, data: "Hello!")
        parts << storage_gateway.upload_part(file_name: "test", upload_id: upload_id, part_number: 2, data: "Hello!")
        expect { storage_gateway.complete_upload(file_name: "test", upload_id: upload_id, parts: parts) }.not_to raise_error
      end
    end
  end
end
