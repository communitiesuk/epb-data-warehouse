describe UseCase::ImportCertificates do
  subject(:use_case) do
    described_class.new import_xml_certificate_use_case:,
                        queues_gateway:,
                        recovery_list_gateway:,
                        logger:
  end

  let(:import_xml_certificate_use_case) do
    instance_double(UseCase::ImportXmlCertificate)
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let(:recovery_list_gateway) do
    recovery_list_gateway = instance_double(Gateway::RecoveryListGateway)
    allow(recovery_list_gateway).to receive(:register_assessments)
    recovery_list_gateway
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let(:schema_type) { "TODO" }

  context "when queues gateway is functioning correctly" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[
        0000-0000-0000-0000-0000
        0000-0000-0000-0000-0001
        0000-0000-0000-0000-0002
      ])
      allow(UseCase::ImportXmlCertificate).to receive(:new).and_return(import_xml_certificate_use_case)
      allow(import_xml_certificate_use_case).to receive(:execute)
    end

    it "calls the import XML certificate use case" do
      expect { use_case.execute }.not_to raise_error

      expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0000", queue_name: :assessments)
      expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0001", queue_name: :assessments)
      expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0002", queue_name: :assessments)
    end

    it "calls the method to removes the assessment id from the redis queue" do
      allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0000", queue_name: :assessments)
      allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0001", queue_name: :assessments)
      allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0002", queue_name: :assessments)

      expect { use_case.execute }.not_to raise_error
    end

    it "registers the assessments from the queue onto the recovery list" do
      use_case.execute
      expect(recovery_list_gateway).to have_received(:register_assessments).with(
        "0000-0000-0000-0000-0000", "0000-0000-0000-0000-0001", "0000-0000-0000-0000-0002",
        queue: :assessments
      )
    end
  end

  context "when queues gateway is not functioning correctly" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_raise("bang!")
    end

    it "logs out an error containing the underlying error message" do
      use_case.execute

      expect(logger).to have_received(:error).with(include "bang!")
    end
  end

  context "when validating the queue name" do
    let(:valid_queue_names) do
      Gateway::QueueNames::QUEUE_NAMES
    end

    it "is is valid" do
      expect(valid_queue_names.include?(:assessments)).to be true
    end
  end

  context "when a custom queue name is provided" do
    subject(:use_case) do
      described_class.new import_xml_certificate_use_case:,
                          queues_gateway:,
                          recovery_list_gateway:,
                          logger:,
                          queue_name:
    end

    let(:queue_name) { :assessments_backfill }

    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001])
      allow(import_xml_certificate_use_case).to receive(:execute)
    end

    it "consumes from the correct queue" do
      use_case.execute
      expect(queues_gateway).to have_received(:consume_queue).with(queue_name)
    end

    it "registers assessments onto the correct recovery list queue" do
      use_case.execute
      expect(recovery_list_gateway).to have_received(:register_assessments).with("0000-0000-0000-0000-0000", "0000-0000-0000-0000-0001", queue: queue_name)
    end

    it "calls the import XML certificate use case with the correct queue name" do
      use_case.execute
      expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0000", queue_name: queue_name)
      expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0001", queue_name: queue_name)
    end

    context "when fetching from the recovery list" do
      before do
        allow(recovery_list_gateway).to receive(:assessments).with(queue: queue_name).and_return(%w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001])
      end

      it "fetches assessments from the correct recovery list queue" do
        use_case.execute from_recovery_list: true
        expect(recovery_list_gateway).to have_received(:assessments).with(queue: queue_name)
      end
    end

    context "when validating the queue name" do
      let(:valid_queue_names) do
        Gateway::QueueNames::QUEUE_NAMES
      end

      it "is is valid" do
        expect(valid_queue_names.include?(queue_name)).to be true
      end
    end
  end

  context "when assessments are being fetched from the recovery list" do
    before do
      allow(recovery_list_gateway).to receive(:assessments).with(queue: :assessments).and_return(%w[
        0000-0000-0000-0000-0000
        0000-0000-0000-0000-0001
        0000-0000-0000-0000-0002
      ])
      allow(UseCase::ImportXmlCertificate).to receive(:new).and_return(import_xml_certificate_use_case)
      allow(import_xml_certificate_use_case).to receive(:execute)

      use_case.execute from_recovery_list: true
    end

    it "calls down to the import XML use case with the three certificates from the recovery list" do
      expect(import_xml_certificate_use_case).to have_received(:execute).exactly(3).times
    end

    it "does not register the assessments back onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received :register_assessments
    end
  end
end
