describe "HomeController" do
  include RSpecDataWarehouseApiServiceMixin

  context "when getting a response from /" do
    let(:response) { get "/" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "returns Hello World" do
      expect(response.body).to eq("Hello world!")
    end
  end
end
