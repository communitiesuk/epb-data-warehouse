shared_examples "when checking an endpoint requires bearer token access" do |end_point:|
  context "when making an invalid request to #{end_point}" do
    let(:response) do
      get "/api/#{end_point}"
    end

    it "returns status 403" do
      expect(response.status).to eq(403)
    end

    it "raises an error due to the missing token" do
      expect(response.body).to include "You are not authenticated"
    end
  end
end
