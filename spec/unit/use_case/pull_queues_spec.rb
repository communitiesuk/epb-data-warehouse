describe UseCase::PullQueues do
  subject(:use_case) { described_class.new }

  use_case_classes = [
    UseCase::ImportCertificates,
    UseCase::CancelCertificates,
    UseCase::OptOutCertificates,
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

    it "executes all of the sub use cases" do
      use_case.execute

      expect(instances).to all(have_received(:execute))
    end
  end
end
