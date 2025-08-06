require "aws-sdk-s3"

describe UseCase::GetPresignedUrl do
  let(:gateway) do
    instance_double(Gateway::S3Gateway)
  end

  let(:use_case) do
    described_class.new(gateway:, bucket_name:)
  end

  let(:bucket_name) do
    "user-data"
  end

  let(:signed_url) do
    "https://user-data.s3.us-stubbed-1.amazonaws.com/folder/test.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20250425%2Fus-stubbed-1%2Fs3%2Faws4_request&X-Amz-Date=20250425T093253Z&X-Amz-Expires=30&X-Amz-SignedHeaders=host&X-Amz-Signature=d2100aa041ef076ad44f0e0dd5e6dd187c87aaf11d434f21646070d8eddf9350"
  end

  describe "#execute" do
    context "when the file path is found in s3" do
      before do
        allow(gateway).to receive(:get_presigned_url).and_return(signed_url)
      end

      it "calls the correct gateway method" do
        expect(use_case.execute(file_name: "folder/test.csv")).to eq signed_url
      end

      it "passes the arguments to the gateway method" do
        use_case.execute(file_name: "folder/test.csv")
        expect(gateway).to have_received(:get_presigned_url).with(bucket: bucket_name, file_name: "folder/test.csv", expires_in: 30)
      end
    end

    context "when the file path is not found" do
      before do
        allow(gateway).to receive(:get_presigned_url).and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "NoSuchKey"))
      end

      it "raises a file not found error" do
        expect { use_case.execute(file_name: "folder/none.csv") }.to raise_error(Errors::FileNotFound)
      end
    end
  end
end
