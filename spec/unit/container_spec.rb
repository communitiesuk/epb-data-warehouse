require_relative "../shared_context/shared_send_heat_pump"

describe Container do
  include_context "when sending heat pump data"

  before do
    ENV["NOTIFY_CLIENT_API_KEY"] = notify_client_test_api_key
    ENV["BUCKET_NAME"] = "bucket"
  end

  after do
    ENV["NOTIFY_CLIENT_API_KEY"] = nil
    ENV["BUCKET_NAME"] = nil
  end

  it "checks all the factory methods can execute correctly" do
    described_class.methods(false).each do |method|
      expect { described_class.send method }.not_to raise_error
    end
  end
end
