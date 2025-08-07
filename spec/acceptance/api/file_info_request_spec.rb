describe "get .get-energy-certificate-data.epb-frontend/info" do
  include RSpecDataWarehouseApiServiceMixin

  let(:file_name) do
    "domestic"
  end

  let(:file_path) do
    "domestic/full-load/domestic.zip"
  end

  let(:response) do
    header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
    get "/api/files/#{file_name}/info"
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
