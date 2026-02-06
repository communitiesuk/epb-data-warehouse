require "time"

describe UseCase::UpdateCertificateMatchedAddressesBackfill do
  subject(:use_case) do
    described_class.new queues_gateway:,
                        documents_gateway:,
                        assessment_search_gateway:,
                        recovery_list_gateway:,
                        logger:
  end

  let(:queue_name) do
    :backfill_matched_address_update
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    allow(documents_gateway).to receive(:check_id_exists?).and_return(true)
    allow(documents_gateway).to receive(:update_matched_uprn)
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

  context "when listening to the backfill queue" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(payload)
    end

    it "fetches the correct queue" do
      use_case.execute
      expect(queues_gateway).to have_received(:consume_queue).with(queue_name).exactly(1).times
    end

    it "updates the relevant certificates in the document store without updating 'updated_at' value" do
      use_case.execute
      expect(documents_gateway).to have_received(:update_matched_uprn).exactly(3).times
      expect(documents_gateway).to have_received(:update_matched_uprn).with(
        assessment_id: "0000-0000-0000-0000-0000",
        matched_uprn: "4444444444",
        update: false,
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
