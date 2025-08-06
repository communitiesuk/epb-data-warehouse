require "aws-sdk-s3"

describe Gateway::S3Gateway do
  subject(:gateway) { described_class.new(s3_client:) }

  let(:s3_client) do
    Aws::S3::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  describe "#get_presigned_url" do
    before(:all) do
      WebMock.enable!
    end

    after(:all) do
      WebMock.disable!
    end

    context "when creating a presigned url of an existing file" do
      let(:signed_url) do
        gateway.get_presigned_url(bucket: "user-data", file_name: "folder/test.csv", expires_in: 60)
      end

      before do
        WebMock.stub_request(:head, "https://user-data.s3.eu-west-2.amazonaws.com/folder/test.csv")
               .to_return(status: 200)
      end

      it "returns a url of the bucket path, folder and file name" do
        expect(signed_url).to include("https://user-data.s3.eu-west-2.amazonaws.com/folder/test.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256")
      end

      it "the url has the correct expiry time" do
        expect(signed_url).to include("Expires=60")
      end
    end

    context "when creating a presigned url of an non-existing file" do
      before do
        WebMock.stub_request(:head, "https://user-data.s3.eu-west-2.amazonaws.com/non-existing-file.zip")
               .to_return(status: 404)
      end

      it "raises a FileNotFound error" do
        expect { gateway.get_presigned_url(bucket: "user-data", file_name: "non-existing-file.zip", expires_in: 60) }.to raise_error(Errors::FileNotFound, "non-existing-file.zip")
      end
    end
  end
end
