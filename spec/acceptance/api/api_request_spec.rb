describe "HomeController" do
  include RSpecDataWarehouseApiServiceMixin

  context "when requesting a response from / with no token" do
    let(:response) { get "/" }

    it "returns status 401" do
      expect(response.status).to eq(401)
    end

    it "raises an error due to the missing token" do
      expect(response.body).to include Auth::Errors::TokenMissing.to_s
    end
  end

  context "when requesting a response from / with the wrong token" do
    let(:response) do
      header("Authorization", "Bearer #{get_valid_jwt(%w[dodgytoken])}")
      get("/")
    end

    it "returns status 403" do
      expect(response.status).to eq(403)
    end

    it "raises an error due to the missing token" do
      expect(response.body).to include "You are not authorised to perform this request"
    end
  end

  context "when requesting a response from / with the correct token" do
    let(:response) do
      header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:test])}")
      get("/")
    end

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "returns Hello World" do
      expect(response.body).to eq("Hello world!")
    end
  end
end
