require "time"

describe UseCase::CancelCertificates do
  subject(:use_case) do
    described_class.new eav_gateway: eav_database_gateway,
                        queues_gateway: queues_gateway,
                        api_gateway: api_gateway,
                        documents_gateway: documents_gateway,
                        recovery_list_gateway: recovery_list_gateway,
                        logger: logger
  end

  let(:eav_database_gateway) do
    eav_database_gateway = instance_double(Gateway::AssessmentAttributesGateway)
    allow(eav_database_gateway).to receive(:delete_attributes_by_assessment)
    eav_database_gateway
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    allow(documents_gateway).to receive(:delete_assessment)
    documents_gateway
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let(:api_gateway) do
    gateway = instance_double(Gateway::RegisterApiGateway)
    allow(gateway).to receive(:fetch_meta_data)
    gateway
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

  context "when the queues gateway is functioning correctly" do
    before do
      allow(eav_database_gateway).to receive(:delete_attributes_by_assessment).and_return(true)
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
    end

    context "when processing cancellations where there is a cancelled_at attribute present" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).and_return({ cancelledAt: "2021-08-13T08:12:51.205Z" })
      end

      it "saves the relevant certificates to database" do
        expect { use_case.execute }.not_to raise_error
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(3).times
      end

      it "passes the relevant certificates to the documents gateway" do
        use_case.execute
        expect(documents_gateway).to have_received(:delete_assessment).exactly(3).times
      end

      it "clears the assessments from the recovery list" do
        use_case.execute
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end
    end

    context "when processing cancellations where there is a certificate without a cancelled_at date" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3) })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3) })
        use_case.execute
      end

      it "skips over the certificate whose cancellation date is null" do
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(2).times
      end

      it "clears all the assessments from the recovery list regardless of cancelled_at date" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end
    end

    context "when processing cancellations where one of the cancellations is of type AC-REPORT and therefore excluded" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "AC-REPORT" })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC" })
        use_case.execute
      end

      it "skips over the certificate whose cancellation date is null" do
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(1).times
      end

      it "clears all the assessments from the recovery list regardless of type of assessment" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end
    end

    context "when processing cancellations where fetching metadata for one of them fails" do
      failed_assessment = "1235-0000-0000-0000-0000"

      before do
        allow(api_gateway).to receive(:fetch_meta_data) do |rrn|
          raise StandardError, "fetching metadata for this RRN failed" if rrn == failed_assessment

          { cancelledAt: Time.now.utc.iso8601(3) }
        end
        use_case.execute
      end

      it "sends the updates for the other two certificates to the EAV store" do
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(2).times
      end

      it "sends the updates for the other two certificates to the document store" do
        expect(documents_gateway).to have_received(:delete_assessment).exactly(2).times
      end

      it "clears the other two certificates/ assessments from the recovery list" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(2).times
      end

      it "registers an attempt for the assessment that failed" do
        expect(recovery_list_gateway).to have_received(:register_attempt).with(assessment_id: failed_assessment, queue: :cancelled)
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
      allow(recovery_list_gateway).to receive(:assessments).with(queue: :cancelled).and_return(%w[
        0000-0000-0000-0000-0000
        0000-0000-0000-0000-0001
        0000-0000-0000-0000-0002
      ])
      allow(api_gateway).to receive(:fetch_meta_data).and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC" })
      use_case.execute from_recovery_list: true
    end

    it "sends updates for all three certificates from the recovery list" do
      expect(documents_gateway).to have_received(:delete_assessment).exactly(3).times
    end

    it "does not register the assessments onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_assessments)
    end
  end
end
