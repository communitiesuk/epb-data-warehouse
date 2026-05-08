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

  describe ".import_certificates_use_case" do
    it "uses a ScoredRecoveryListGateway as the recovery_list_gateway" do
      gateway = described_class.import_certificates_use_case.instance_variable_get(:@recovery_list_gateway)
      expect(gateway).to be_an_instance_of(Gateway::ScoredRecoveryListGateway)
    end
  end

  describe ".import_certificates_backfill_use_case" do
    it "uses a ScoredRecoveryListGateway as the recovery_list_gateway" do
      gateway = described_class.import_certificates_backfill_use_case.instance_variable_get(:@recovery_list_gateway)
      expect(gateway).to be_an_instance_of(Gateway::ScoredRecoveryListGateway)
    end
  end

  describe ".import_xml_certificate_use_case" do
    it "uses a ScoredRecoveryListGateway as the recovery_list_gateway" do
      gateway = described_class.import_xml_certificate_use_case.instance_variable_get(:@recovery_list_gateway)
      expect(gateway).to be_an_instance_of(Gateway::ScoredRecoveryListGateway)
    end
  end

  describe ".update_certificate_matched_addresses_use_case" do
    it "uses a ScoredRecoveryListGateway as the recovery_list_gateway" do
      gateway = described_class.update_certificate_matched_addresses_use_case.instance_variable_get(:@recovery_list_gateway)
      expect(gateway).to be_an_instance_of(Gateway::ScoredRecoveryListGateway)
    end
  end

  describe ".backfill_update_certificate_matched_addresses_use_case" do
    it "uses a ScoredRecoveryListGateway as the recovery_list_gateway" do
      gateway = described_class.backfill_update_certificate_matched_addresses_use_case.instance_variable_get(:@recovery_list_gateway)
      expect(gateway).to be_an_instance_of(Gateway::ScoredRecoveryListGateway)
    end
  end
end
