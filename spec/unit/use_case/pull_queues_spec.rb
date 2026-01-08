describe UseCase::PullQueues do
  subject(:use_case) { described_class.new }

  use_case_classes = [
    UseCase::ImportCertificates,
    UseCase::CancelCertificates,
    UseCase::OptOutCertificates,
    UseCase::UpdateCertificateAddresses,
    UseCase::UpdateCertificateMatchedAddresses,
  ]

  context "when executing the use case" do
    instances = []

    before do
      use_case_classes.each do |sub_case_class|
        use_case_instance = instance_double(sub_case_class)
        allow(sub_case_class).to receive(:new).and_return use_case_instance
        allow(use_case_instance).to receive(:execute)
        instances << use_case_instance
      end
    end

    after { instances = [] }

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
end
