describe UseCase::PullQueues do
  subject(:use_case) { described_class.new }

  let(:import_certificates_instance) { instance_double(UseCase::ImportCertificates) }
  let(:import_certificates_backfill_instance) { instance_double(UseCase::ImportCertificates) }
  let(:cancel_certificates_instance) { instance_double(UseCase::CancelCertificates) }
  let(:opt_out_certificates_instance) { instance_double(UseCase::OptOutCertificates) }
  let(:update_certificate_addresses_instance) { instance_double(UseCase::UpdateCertificateAddresses) }
  let(:update_certificate_matched_addresses_instance) { instance_double(UseCase::UpdateCertificateMatchedAddresses) }
  let(:backfill_update_certificate_matched_addresses_instance) { instance_double(UseCase::UpdateCertificateMatchedAddressesBackfill) }

  let(:instances) do
    [
      import_certificates_instance,
      import_certificates_backfill_instance,
      cancel_certificates_instance,
      opt_out_certificates_instance,
      update_certificate_addresses_instance,
      update_certificate_matched_addresses_instance,
      backfill_update_certificate_matched_addresses_instance,
    ]
  end

  before do
    allow(Container).to receive_messages(
      import_certificates_use_case: import_certificates_instance,
      import_certificates_backfill_use_case: import_certificates_backfill_instance,
      cancel_certificates_use_case: cancel_certificates_instance,
      opt_out_certificates_use_case: opt_out_certificates_instance,
      update_certificate_addresses_use_case: update_certificate_addresses_instance,
      update_certificate_matched_addresses_use_case: update_certificate_matched_addresses_instance,
      backfill_update_certificate_matched_addresses_use_case: backfill_update_certificate_matched_addresses_instance,
    )

    instances.each { |instance| allow(instance).to receive(:execute) }
  end

  context "when not specifying the from_recovery_list option" do
    it "executes all of the sub use cases" do
      use_case.execute

      expect(instances).to all(have_received(:execute))
    end
  end

  context "when specifying the from_recovery_list option" do
    it "executes all of the sub use cases specifying the from_recovery_list option" do
      use_case.execute from_recovery_list: true

      expect(instances).to all(have_received(:execute).with(from_recovery_list: true))
    end
  end
end
