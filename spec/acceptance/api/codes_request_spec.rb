describe "CodesController" do
  include RSpecDataWarehouseApiServiceMixin
  context "when requesting a response from /api/codes" do
    context "when the response is a success" do
      before do
        allow(Container).to receive(:fetch_look_ups_use_case).and_return(use_case)
        allow(use_case).to receive(:execute).and_return(%w[energy_tariff floor_level])
      end

      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:read])}")
        get "/api/codes"
      end

      let(:use_case) do
        instance_double(UseCase::FetchLookups)
      end

      let(:body) do
        JSON.parse(response.body)
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "returns an array of lookup string" do
        expect(body["data"]).to eq %w[energy_tariff floor_level]
      end
    end
  end
end
