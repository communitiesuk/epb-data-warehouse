require "aws-sdk-s3"

describe UseCase::GetFileInfo do
  let(:gateway) do
    instance_double(Gateway::S3Gateway)
  end

  let(:use_case) do
    described_class.new(gateway:, bucket_name:)
  end

  let(:bucket_name) do
    "user-data"
  end

  let(:expected_hash) do
    {
      file_size: 3600,
      last_modified: Time.parse("2006-01-01 12:00:00 UTC"),
    }
  end

  describe "#execute" do
    context "when the file path is found in s3" do
      before do
        allow(gateway).to receive(:get_file_info).and_return(expected_hash)
      end

      it "returns the expected hash" do
        expect(use_case.execute(file_name: "folder/test.csv")).to eq expected_hash
      end

      it "passes the arguments to the gateway method" do
        use_case.execute(file_name: "folder/test.csv")
        expect(gateway).to have_received(:get_file_info).with(bucket: bucket_name, file_name: "folder/test.csv")
      end
    end

    context "when the file path is not found" do
      before do
        allow(gateway).to receive(:get_file_info).and_raise(Aws::S3::Errors::NoSuchKey.new(nil, "NoSuchKey"))
      end

      it "raises a file not found error" do
        expect { use_case.execute(file_name: "folder/banana.csv") }.to raise_error(Errors::FileNotFound)
      end
    end
  end
end
