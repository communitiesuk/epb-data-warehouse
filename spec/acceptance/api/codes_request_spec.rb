describe "CodesController" do
  include RSpecDataWarehouseApiServiceMixin
  before do
    stub_bearer_token_access
  end

  context "when requesting a response from /api/codes" do
    context "when the response is a success" do
      let(:use_case) do
        instance_double(UseCase::FetchLookups)
      end
      let(:response) do
        get "/api/codes"
      end
      let(:authenticate_user_use_case) do
        instance_double(UseCase::AuthenticateUser)
      end
      let(:body) do
        JSON.parse(response.body)
      end

      before do
        allow(Container).to receive(:fetch_look_ups_use_case).and_return(use_case)
        allow(use_case).to receive(:execute).and_return(%w[energy_tariff floor_level])
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "returns an array of lookup string" do
        expect(body["data"]).to eq %w[energy_tariff floor_level]
      end
    end
  end

  context "when requesting a response from /api/codes/info?code=built_form" do
    let(:use_case) do
      instance_double(UseCase::FetchLookupValues)
    end

    context "when the response is a success" do
      let(:data)  do
        [{ "key" => "1", "values" => ["value" => "test", "schema_version" => "RdSAP-21.0.0"] }, { "key" => "2", "values" => ["value" => "something", "schema_version" => "CEPC-8.0.0"] }]
      end
      let(:response) do
        get "/api/codes/info?code=built_form"
      end

      let(:response_data) do
        [{ "key" => "1", "values" => ["value" => "test", "schemaVersion" => "RdSAP-21.0.0"] }, { "key" => "2", "values" => ["value" => "something", "schemaVersion" => "CEPC-8.0.0"] }]
      end

      before do
        allow(Container).to receive(:fetch_look_up_values_use_case).and_return(use_case)
        allow(use_case).to receive(:execute).and_return data
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "returns the expected data" do
        expect(JSON.parse(response.body)["data"]).to eq response_data
      end
    end

    context "when the no data is found" do
      before do
        allow(Container).to receive(:fetch_look_up_values_use_case).and_return(use_case)
        allow(use_case).to receive(:execute).and_raise Boundary::NoData, "No data"
      end

      let(:response) do
        get "/api/codes/info?code=built_form"
      end

      it "returns 404" do
        expect(response.status).to eq(404)
      end
    end
  end
end
