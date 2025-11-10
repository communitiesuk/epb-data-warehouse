shared_examples "a file download API endpoint" do |file_name:, type:|
  context "when requesting a #{file_name} #{type} file" do
    let(:file_path) do
      "full-load/#{file_name}"
    end

    let(:response) do
      header("Authorization", "Bearer valid-bearer-token")
      get "/api/files/#{file_name}/#{type}"
    end

    let(:authenticate_user_use_case) do
      instance_double(UseCase::AuthenticateUser)
    end

    before do
      allow(authenticate_user_use_case).to receive(:execute).with("valid-bearer-token").and_return(true)
      allow(Container).to receive_messages(authenticate_user_use_case: authenticate_user_use_case)
    end

    context "when the request is not authorized" do
      let(:no_auth_header_response) do
        get "/api/files/#{file_name}/#{type}"
      end

      it "returns 403" do
        expect(no_auth_header_response.status).to eq(403)
      end
    end

    context "when the file exists" do
      it "returns the redirect status" do
        expect(response.status).to eq(302)
      end

      it "redirects to file download" do
        expect(response.headers["location"]).to include("https://user-data.s3.us-stubbed-1.amazonaws.com/#{file_path}-#{type}.zip?X-Amz-Algorithm=AWS4-HMAC")
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
end

shared_examples "a file info API endpoint" do |file_name:, type:|
  let(:response) do
    get "/api/files/#{file_name}/#{type}/info"
  end

  context "when requesting a #{file_name} #{type} file" do
    before do
      stub_bearer_token_access
      Timecop.freeze("2025-01-01 12:00:00 UTC")
    end

    after { Timecop.return }

    it "returns 200" do
      expect(response.status).to eq(200)
    end

    it "returns data in json format" do
      expect(response.content_type).to eq("application/json")
    end

    it "returns correct file info hash" do
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]).to eq({ "fileSize" => 0, "lastUpdated" => "2025-01-01T12:00:00.000+00:00" })
    end
  end

  context "when no file is found" do
    let(:use_case) do
      instance_double(UseCase::GetFileInfo)
    end

    before do
      stub_bearer_token_access
      allow(Container).to receive(:get_file_info_use_case).and_return(use_case)
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

  context "when the request is not authorized" do
    it "returns 403" do
      expect(response.status).to eq(403)
    end
  end
end
