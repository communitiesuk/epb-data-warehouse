require "time"

describe UseCase::UpdateCertificateAddresses do
  subject(:use_case) do
    described_class.new eav_gateway: eav_database_gateway,
                        queues_gateway:,
                        documents_gateway:,
                        recovery_list_gateway:,
                        logger:
  end

  let(:eav_database_gateway) do
    eav_database_gateway = instance_double(Gateway::AssessmentAttributesGateway)
    allow(eav_database_gateway).to receive(:update_assessment_attribute)
    eav_database_gateway
  end

  let(:queue_name) do
    :assessments_address_update
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    allow(documents_gateway).to receive(:set_top_level_attribute)
    documents_gateway
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let(:recovery_list_gateway) do
    gateway = instance_double(Gateway::RecoveryListGateway)
    allow(gateway).to receive(:clear_assessment)
    allow(gateway).to receive(:register_attempt)
    allow(gateway).to receive(:register_assessments)
    gateway
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let(:payload) do
    %w[0000-0000-0000-0000-0000:UPRN-4444444444 0000-0000-0000-0000-0001:RRN-0000-0000-0000-0000-0001 0000-0000-0000-0000-0003:RRN-0000-0000-0000-0000-0003]
  end

  context "when the queues gateway is functioning correctly" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(payload)
    end

    context "when processing updates" do
      it "runs without errors" do
        expect { use_case.execute }.not_to raise_error
      end

      it "fetches the correct queue" do
        use_case.execute
        expect(queues_gateway).to have_received(:consume_queue).with(queue_name).exactly(1).times
      end

      it "updates the relevant certificates in the EAV store" do
        use_case.execute
        expect(eav_database_gateway).to have_received(:update_assessment_attribute).exactly(3).times
        expect(eav_database_gateway).to have_received(:update_assessment_attribute).with(assessment_id: "0000-0000-0000-0000-0003", attribute: "assessment_address_id", value: "RRN-0000-0000-0000-0000-0003").exactly(1).times
      end

      it "updates the relevant certificates in the document store" do
        use_case.execute
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
        expect(documents_gateway).to have_received(:set_top_level_attribute).with(assessment_id: "0000-0000-0000-0000-0000", top_level_attribute: "assessment_address_id", new_value: "UPRN-4444444444").exactly(1).times
      end

      it "clears the assessments from the recovery list" do
        use_case.execute
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end
    end
  end

  context "when the queues gateway is not functioning correctly" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_raise("bang!")
    end

    it "logs out an error containing the underlying error message" do
      use_case.execute

      expect(logger).to have_received(:error).with(include "bang!")
    end
  end

  context "when assessments are being fetched from the recovery list" do
    before do
      allow(recovery_list_gateway).to receive(:assessments).with(queue: queue_name).and_return(payload)
      use_case.execute from_recovery_list: true
    end

    it "sends updates for all three certificates from the recovery list" do
      expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
    end

    it "does not register the assessments onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_assessments)
    end
  end
end
