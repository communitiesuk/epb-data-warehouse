describe "ApiService" do
  include RSpecDataWarehouseApiServiceMixin

  context "when getting a response from /healthcheck" do
    let(:response) { get "/healthcheck" }

    it "returns status 200" do
      expect(response.status).to eq(200)
    end
  end

  context "when getting a response from an unknown route" do
    let(:response) do
      get "/does-not-exist"
    end

    it "returns status 404" do
      expect(response.status).to eq(404)
      expect(response.body).to eq "<h1>Not Found</h1>"
    end
  end

  context "when an uncaught error is raised" do
    let(:exception) { "boom" }
    let(:app) do
      test_exception = exception
      Class.new(DataWarehouseApiService) do
        set :raise_errors, false
        set :show_exceptions, false

        get "/test-error" do
          raise test_exception
        end
      end
    end

    context "when an uncaught error is raised" do
      before do
        stub_bearer_token_access
        get "/test-error"
      end

      it "responds with a 500 status" do
        expect(last_response.status).to eq 500
      end

      it "does not display a verbose error message" do
        expect(last_response.body).to eq "SERVER ERROR"
      end
    end

    context "when in a development environment" do
      before do
        app.set :host_authorization, { permitted_hosts: %w[] }
        app.set :environment, :development

        stub_bearer_token_access
        get "/test-error"
      end

      it "responds with a 500 status" do
        expect(last_response.status).to eq 500
      end

      it "displays a verbose error message" do
        expect(JSON.parse(last_response.body)).to eq("backtrace" => [], "message" => "boom", "type" => "RuntimeError")
      end
    end
  end
end
