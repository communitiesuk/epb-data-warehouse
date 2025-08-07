describe "get .get-energy-certificate-data.epb-frontend/download" do
  include RSpecDataWarehouseApiServiceMixin

  let(:file_name) do
    "domestic"
  end

  let(:file_path) do
    "domestic/full-load/domestic.zip"
  end

  let(:response) do
    header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
    get "/api/files/#{file_name}"
  end

  context "when the file exists" do
    it "returns the redirect status" do
      expect(response.status).to eq(302)
    end

    it "redirects to file download" do
      expect(response.headers["location"]).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/#{file_path}?X-Amz-Algorithm=AWS4-HMAC")
    end
  end

  context "when no file is found" do
    let(:use_case) do
      instance_double(UseCase::GetPresignedUrl)
    end

    before do
      allow(Container).to receive(:get_presigned_url_use_case).and_return(use_case)
      allow(use_case).to receive(:execute).and_raise(Errors::FileNotFound)
    end

    it "raises a 404" do
      expect(response.status).to eq(404)
    end

    it "returns a file not found error" do
      response_body = JSON.parse(response.body)
      expect(response_body["data"]["error"]).to include "File not found"
    end
  end

  context "when there is an unexpected error" do
    let(:use_case) do
      instance_double(UseCase::GetPresignedUrl)
    end

    before do
      allow(Container).to receive(:get_presigned_url_use_case).and_return(use_case)
      allow(use_case).to receive(:execute).and_raise(Errors::UriTooLong)
    end

    it "raises a server error" do
      response_body = JSON.parse(response.body)
      expect(response.status).to eq(500)
      expect(response_body["data"]["error"]).to include "Internal Server Error"
    end
  end
end
