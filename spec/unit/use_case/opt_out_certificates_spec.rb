describe UseCase::OptOutCertificates, :set_with_timecop do
  subject(:use_case) do
    described_class.new eav_gateway: database_gateway,
                        documents_gateway:,
                        queues_gateway:,
                        certificate_gateway:,
                        recovery_list_gateway:,
                        audit_logs_gateway:,
                        assessment_search_gateway:,
                        logger:
  end

  let(:database_gateway) do
    database_gateway = instance_double(Gateway::AssessmentAttributesGateway)
    allow(database_gateway).to receive(:add_attribute_value)
    allow(database_gateway).to receive(:delete_attribute_value)
    database_gateway
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    %i[
      set_top_level_attribute
      delete_top_level_attribute
    ].each { |method| allow(documents_gateway).to receive(method) }
    documents_gateway
  end

  let(:queues_gateway) do
    gateway = instance_double(Gateway::QueuesGateway)
    allow(gateway).to receive(:push_to_queue)
    gateway
  end

  let(:certificate_gateway) do
    certificate_gateway = instance_double(Gateway::RegisterApiGateway)
    allow(certificate_gateway).to receive(:fetch_meta_data)
    certificate_gateway
  end

  let(:recovery_list_gateway) do
    gateway = instance_double Gateway::RecoveryListGateway
    allow(gateway).to receive(:clear_assessment)
    allow(gateway).to receive(:register_attempt)
    allow(gateway).to receive(:register_assessments)
    gateway
  end

  let(:audit_logs_gateway) do
    gateway = instance_double(Gateway::AuditLogsGateway)
    allow(gateway).to receive(:insert_log)
    gateway
  end

  let(:assessment_search_gateway) do
    gateway = instance_double(Gateway::AssessmentSearchGateway)
    allow(gateway).to receive(:delete_assessment)
    gateway
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  context "when queues gateway is functioning correctly" do
    assessment_ids = %w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002]

    before do
      allow(queues_gateway).to receive(:consume_queue).and_return(assessment_ids)
    end

    it "stores the certificates onto the recovery list" do
      use_case.execute
      expect(recovery_list_gateway).to have_received(:register_assessments).with(*assessment_ids, queue: :opt_outs)
    end

    context "when marking existing certs as opted out" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
        use_case.execute
      end

      it "saves 3 opted out certificate to the EAV store" do
        expect(database_gateway).to have_received(:delete_attribute_value).exactly(3).times
        expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
      end

      it "saves 3 opted out certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
        expect(documents_gateway).not_to have_received(:delete_top_level_attribute)
      end

      it "clears 3 certificates from the recovery list" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end

      it "inserts 3 logs to the audit logs" do
        expect(audit_logs_gateway).to have_received(:insert_log).exactly(3).times
      end

      it "passes the relevant assessment id to the AssessmentSearchGateway" do
        expect(assessment_search_gateway).to have_received(:delete_assessment).exactly(3).times
      end
    end

    context "when marking one existing cert as opted in" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: false })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
        use_case.execute
      end

      it "performs a save for each of the 3 certificates on the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
      end

      it "performs a delete for each of the 3 certificates to ensure it can write a value, plus a delete of the opt_out attribute for one certificate" do
        expect(database_gateway).to have_received(:delete_attribute_value).exactly(4).times
      end

      it "performs a save for each of the 3 certificates on the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
      end

      it "executes the update use case by deleting one attribute value on the document store" do
        expect(documents_gateway).to have_received(:delete_top_level_attribute).exactly(1).times
      end

      it "uses the expected XXXX-XX-XX XX:XX:XX format for saving the datetime of the opt-out/in" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times.with(include(new_value: Time.now.utc.strftime("%F %T")))
      end

      it "inserts 3 logs to the audit logs" do
        expect(audit_logs_gateway).to have_received(:insert_log).exactly(3).times
      end

      it "the search gateway is called for only the 2 EPC that are opted out" do
        expect(assessment_search_gateway).to have_received(:delete_assessment).exactly(2).times
      end

      it "the opted in EPC is added back onto the assessments queue" do
        expect(queues_gateway).to have_received(:push_to_queue).with(:assessments, "0000-9999-0000-0000-0001").exactly(1).times
      end
    end

    context "when marking existing certs as opted out but one triggers an error" do
      erroring_assessment = "1235-0000-0000-0000-0000"

      before do
        allow(certificate_gateway).to receive(:fetch_meta_data) do |rrn|
          raise StandardError, "could not save for that RRN" if rrn == erroring_assessment

          { optOut: true }
        end
        use_case.execute
      end

      it "saves the two non-erroring opted out certificates to the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end

      it "saves the two non-erroring opted out certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(2).times
      end

      it "clears the two non-erroring assessments from the recovery list" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(2).times
      end

      it "registers a processing attempt on the recovery list for the erroring assessment" do
        expect(recovery_list_gateway).to have_received(:register_attempt).with(payload: erroring_assessment, queue: :opt_outs)
      end
    end

    context "when marking existing certs as opted out but one has type AC-REPORT" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data) do |rrn|
          {
            optOut: true,
            typeOfAssessment: rrn == "1235-0000-0000-0000-0000" ? "AC-REPORT" : "CEPC",
          }
        end
        use_case.execute
      end

      it "saves the two non-AC-REPORT opted out certificates to the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end

      it "saves the two non-AC_REPORT opted out certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(2).times
      end

      it "clears all three certificates from the recovery list" do
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

  context "when the assessments are being fetched from the recovery list" do
    before do
      allow(recovery_list_gateway).to receive(:assessments).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
      allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ optOut: true })

      use_case.execute from_recovery_list: true
    end

    it "saves the certificates from the recovery list to the document store" do
      expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
    end

    it "does not register the assessments onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_assessments)
    end
  end

  context "when the certificate gateway has a bad connection to the api" do
    before do
      allow(recovery_list_gateway).to receive(:assessments).with(queue: :opt_outs).and_return(%w[
        0000-0000-0000-0000-0000
      ])
      allow(certificate_gateway).to receive(:fetch_meta_data).and_raise(Errors::ConnectionApiError)
      use_case.execute(from_recovery_list: true)
    end

    it "does not report an attempt to process the assessment onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_attempt)
    end
  end
end
