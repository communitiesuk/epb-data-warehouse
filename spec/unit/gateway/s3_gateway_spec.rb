require "aws-sdk-s3"

describe Gateway::S3Gateway do
  subject(:gateway) { described_class.new(s3_client:) }

  let(:s3_client) do
    Aws::S3::Client.new(
      region: "eu-west-2",
      credentials: Aws::Credentials.new("fake_access_key_id", "fake_secret_access_key"),
    )
  end

  before(:all) do
    WebMock.enable!
  end

  after(:all) do
    WebMock.disable!
  end

  describe "#get_presigned_url" do
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

  describe "#get_file_info" do
    context "when getting file info of an existing file" do
      let(:response) do
        gateway.get_file_info(bucket: "user-data", file_name: "folder/test.csv")
      end

      before do
        WebMock.stub_request(:head, "https://user-data.s3.eu-west-2.amazonaws.com/folder/test.csv")
               .to_return(
                 status: 200,
                 headers: {
                   "Content-Length" => "3600",
                   "Last-Modified" => Time.parse("2006-01-01 12:00:00 UTC"),
                 },
               )
      end

      it "returns a hash with file size and last updated date" do
        expect(response).to be_a(Hash)
        expect(response).to eq(
          file_size: 3600,
          last_updated: Time.parse("2006-01-01 12:00:00 UTC"),
        )
      end
    end

    context "when getting file info of a non-existing file" do
      before do
        WebMock.stub_request(:head, "https://user-data.s3.eu-west-2.amazonaws.com/banana.zip")
               .to_return(status: 404)
      end

      it "raises a FileNotFound error" do
        expect { gateway.get_file_info(bucket: "user-data", file_name: "banana.zip") }.to raise_error(Errors::FileNotFound, "banana.zip")
      end
    end
  end

  describe "#write_csv_file" do
    let(:data) { [{ built_form: 1, construction_age_band: "2" }, { built_form: 5, construction_age_band: "NR" }] }

    let(:domain) { "https://user-data.s3.eu-west-2.amazonaws.com" }

    before do
      WebMock.stub_request(:put, /#{domain}.*/)
    end

    it "sends the data to s3 to write the file" do
      expect { gateway.write_csv_file(data:, bucket: "user-data", file_name: "look-up.csv") }.not_to raise_error
      expect(WebMock).to have_requested(
        :put,
        "#{domain}/look-up.csv",
      ).with(
        body: 'built_form,construction_age_band
1,2
5,NR
',
      )
    end
  end
end
