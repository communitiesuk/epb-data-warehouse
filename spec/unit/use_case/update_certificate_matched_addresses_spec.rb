require "time"

describe UseCase::UpdateCertificateMatchedAddresses do
  subject(:use_case) do
    described_class.new queues_gateway:,
                        certificate_gateway:,
                        documents_gateway:,
                        assessment_search_gateway:,
                        recovery_list_gateway:,
                        logger:
  end

  let(:queue_name) do
    :matched_address_update
  end

  let(:certificate_gateway) do
    certificate_gateway = instance_double(Gateway::RegisterApiGateway)
    allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                         assessmentAddressId: "UPRN-000000000000",
                                                                         typeOfAssessment: "RdSAP",
                                                                         optOut: false,
                                                                         createdAt: nil })
    certificate_gateway
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    allow(documents_gateway).to receive(:check_id_exists?).and_return(true)
    allow(documents_gateway).to receive(:set_top_level_attribute)
    documents_gateway
  end

  let(:assessment_search_gateway) do
    assessment_search_gateway = instance_double(Gateway::AssessmentSearchGateway)
    allow(assessment_search_gateway).to receive(:update_uprn)
    assessment_search_gateway
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
    %w[0000-0000-0000-0000-0000:4444444444 0000-0000-0000-0000-0001:8888888888 0000-0000-0000-0000-0003:9999999999 0000-0000-0000-0000-0004:none 0000-0000-0000-0000-0005:unknown]
  end

  context "when validating the queue name" do
    let(:valid_queue_names) do
      Gateway::QueueNames::QUEUE_NAMES
    end

    it "is is valid" do
      expect(valid_queue_names.include?(queue_name)).to be true
    end
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

      it "checks the document and search assessment table has the assessment" do
        use_case.execute
        expect(documents_gateway).to have_received(:check_id_exists?).exactly(3).times
      end

      it "fetches the metadata for the assessment" do
        use_case.execute
        expect(certificate_gateway).to have_received(:fetch_meta_data).exactly(3).times
      end

      it "updates the relevant certificates in the document store updating the 'updated_at' value" do
        use_case.execute
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
        expect(documents_gateway).to have_received(:set_top_level_attribute).with(
          assessment_id: "0000-0000-0000-0000-0000",
          top_level_attribute: "matched_uprn",
          new_value: "4444444444",
          update: true,
        ).exactly(1).times
      end

      it "updates the assessment search table" do
        use_case.execute
        expect(assessment_search_gateway).to have_received(:update_uprn).exactly(3).times
        expect(assessment_search_gateway).to have_received(:update_uprn).with(
          assessment_id: "0000-0000-0000-0000-0001",
          new_value: "8888888888",
          override: false,
        ).exactly(1).times
      end

      it "clears the assessments from the recovery list" do
        use_case.execute
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(5).times
      end
    end
  end

  context "when the assessment is not yet in the document or search assessment table" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(payload)
      allow(documents_gateway).to receive(:check_id_exists?).and_return(false)
    end

    it "checks the document and search assessment table has the assessment" do
      use_case.execute
      expect(documents_gateway).to have_received(:check_id_exists?).exactly(3).times
    end

    it "does not attempt to update the documents table" do
      use_case.execute
      expect(documents_gateway).not_to have_received(:set_top_level_attribute)
    end

    it "does not attempt to update the search assessments table" do
      use_case.execute
      expect(assessment_search_gateway).not_to have_received(:update_uprn)
    end

    it "does not clear the assessments with a valid matched uprn from the recovery list" do
      use_case.execute
      expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(2).times
    end
  end

  context "when the assessment should not be imported to the data warehouse" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(payload)
      allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                           assessmentAddressId: "UPRN-000000000000",
                                                                           typeOfAssessment: "RdSAP",
                                                                           optOut: false,
                                                                           createdAt: nil,
                                                                           greenDeal: true })
    end

    it "fetches the metadata for the assessment" do
      use_case.execute
      expect(certificate_gateway).to have_received(:fetch_meta_data).exactly(3).times
    end

    it "does not attempt to update the documents table" do
      use_case.execute
      expect(documents_gateway).not_to have_received(:set_top_level_attribute)
    end

    it "does not attempt to update the search assessments table" do
      use_case.execute
      expect(assessment_search_gateway).not_to have_received(:update_uprn)
    end

    it "clears the assessments from the recovery list" do
      use_case.execute
      expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(5).times
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
      expect(assessment_search_gateway).to have_received(:update_uprn).exactly(3).times
    end

    it "does not register the assessments onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_assessments)
    end
  end
end
