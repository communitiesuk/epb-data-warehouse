describe "get .get-energy-certificate-data.epb-frontend/domestic/csv/info" do
  include RSpecDataWarehouseApiServiceMixin

  context "when requesting csv format" do
    let(:response) do
      header("Authorization", "Bearer valid-bearer-token")
      get "/api/files/domestic/csv/info"
    end

    let(:authenticate_user_use_case) do
      instance_double(UseCase::AuthenticateUser)
    end

    before do
      allow(Container).to receive(:authenticate_user_use_case).and_return(authenticate_user_use_case)
      allow(authenticate_user_use_case).to receive(:execute).with("valid-bearer-token").and_return(true)
      header("Authorization", "Bearer valid-bearer-token")
    end

    context "when the file exists" do
      before { Timecop.freeze("2025-01-01 12:00:00 UTC") }

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
  end

  context "when requesting json format" do
    let(:response) do
      header("Authorization", "Bearer valid-bearer-token")
      get "/api/files/domestic/json/info"
    end

    let(:authenticate_user_use_case) do
      instance_double(UseCase::AuthenticateUser)
    end

    before do
      allow(Container).to receive(:authenticate_user_use_case).and_return(authenticate_user_use_case)
      allow(authenticate_user_use_case).to receive(:execute).with("valid-bearer-token").and_return(true)
      header("Authorization", "Bearer valid-bearer-token")
    end

    context "when the file exists" do
      before { Timecop.freeze("2025-01-01 12:00:00 UTC") }

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
  end
end
