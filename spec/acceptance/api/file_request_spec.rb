describe "FileController" do
  include RSpecDataWarehouseApiServiceMixin

  let(:file_path) do
    "domestic/full-load/domestic.zip"
  end

  let(:response) do
    header("Authorization", "Bearer valid-bearer-token")
    get "/api/files/domestic/csv"
  end

  let(:authenticate_user_use_case) do
    instance_double(UseCase::AuthenticateUser)
  end

  before do
    allow(Container).to receive(:authenticate_user_use_case).and_return(authenticate_user_use_case)
    allow(authenticate_user_use_case).to receive(:execute).and_return(true)
  end

  context "when not setting Authentication header" do
    let(:no_auth_header_response) do
      get "/api/files/domestic/csv"
    end

    it "returns 403" do
      expect(no_auth_header_response.status).to eq(403)
    end
  end

  context "when Authentication header is not a Bearer token" do
    let(:no_bearer_response) do
      header("Authorization", "")
      get "/api/files/domestic/csv"
    end

    it "returns 403" do
      expect(no_bearer_response.status).to eq(403)
    end
  end

  context "when Authentication token does not exist" do
    before do
      allow(authenticate_user_use_case).to receive(:execute).and_return(false)
    end

    let(:non_existing_bearer_response) do
      header("Authorization", "Bearer invalid-token")
      get "/api/files/domestic/csv"
    end

    it "returns 403" do
      expect(non_existing_bearer_response.status).to eq(403)
    end
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
