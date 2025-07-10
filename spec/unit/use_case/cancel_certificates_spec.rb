require "time"

describe UseCase::CancelCertificates do
  subject(:use_case) do
    described_class.new eav_gateway: eav_database_gateway,
                        queues_gateway:,
                        api_gateway:,
                        documents_gateway:,
                        recovery_list_gateway:,
                        audit_logs_gateway:,
                        logger:,
                        assessments_country_id_gateway:,
                        assessment_search_gateway:
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

  let(:audit_logs_gateway) do
    gateway = instance_double(Gateway::AuditLogsGateway)
    allow(gateway).to receive(:insert_log)
    gateway
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let(:assessments_country_id_gateway) do
    gateway = instance_double(Gateway::AssessmentsCountryIdGateway)
    allow(gateway).to receive(:delete_assessment)
    gateway
  end

  let(:assessment_search_gateway) do
    gateway = instance_double(Gateway::AssessmentSearchGateway)
    allow(gateway).to receive(:delete_assessment)
    gateway
  end

  context "when the queues gateway is functioning correctly" do
    before do
      allow(eav_database_gateway).to receive(:delete_attributes_by_assessment).and_return(true)
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
    end

    context "when processing cancellations where there is a cancelled_at attribute present" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).and_return({ cancelledAt: "2021-08-13T08:12:51.205Z", notForIssueAt: nil })
      end

      it "saves the relevant certificates to database" do
        expect { use_case.execute }.not_to raise_error
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(3).times
      end

      it "passes the relevant certificates to the documents gateway" do
        use_case.execute
        expect(documents_gateway).to have_received(:delete_assessment).exactly(3).times
      end

      it "passes the relevant assessment id to the AssessmentsCountryIdGateway" do
        use_case.execute
        expect(assessments_country_id_gateway).to have_received(:delete_assessment).exactly(3).times
      end

      it "passes the relevant assessment id to the AssessmentSearchGateway" do
        use_case.execute
        expect(assessment_search_gateway).to have_received(:delete_assessment).exactly(3).times
      end

      it "clears the assessments from the recovery list" do
        use_case.execute
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end

      it "inserts 3 logs to the audit logs" do
        use_case.execute
        expect(audit_logs_gateway).to have_received(:insert_log).exactly(3).times
      end
    end

    context "when processing cancellations where there is a certificate without a cancelled_at date" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3), notForIssueAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil, notForIssueAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3), notForIssueAt: nil })
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
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "AC-REPORT", notForIssueAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil, notForIssueAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC", notForIssueAt: nil })
        use_case.execute
      end

      it "skips over the certificate whose cancellation date is null" do
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(1).times
      end

      it "clears all the assessments from the recovery list regardless of type of assessment" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).exactly(3).times
      end
    end

    context "when processing cancellations where one of the cancellations is a not-for-issue and therefore has a notForIssueAt rather than a cancelledAt" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC", notForIssueAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil, typeOfAssessment: "DEC", notForIssueAt: Time.now.utc.xmlschema(3) })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC", notForIssueAt: nil })
        use_case.execute
      end

      it "deletes all assessments from the EAV store" do
        expect(eav_database_gateway).to have_received(:delete_attributes_by_assessment).exactly(3).times
      end

      it "deletes all assessments from the document store" do
        expect(documents_gateway).to have_received(:delete_assessment).exactly(3).times
      end

      it "clears all the assessments from the recovery list" do
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
        expect(recovery_list_gateway).to have_received(:register_attempt).with(payload: failed_assessment, queue: :cancelled)
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
      allow(api_gateway).to receive(:fetch_meta_data).and_return({ cancelledAt: Time.now.utc.xmlschema(3), typeOfAssessment: "DEC", notForIssueAt: nil })
      use_case.execute from_recovery_list: true
    end

    it "sends updates for all three certificates from the recovery list" do
      expect(documents_gateway).to have_received(:delete_assessment).exactly(3).times
    end

    it "does not register the assessments onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_assessments)
    end
  end

  context "when the api gateway has a bad connection to the api" do
    before do
      allow(recovery_list_gateway).to receive(:assessments).with(queue: :cancelled).and_return(%w[
        0000-0000-0000-0000-0000
      ])
      allow(api_gateway).to receive(:fetch_meta_data).and_raise(Errors::ConnectionApiError)
      use_case.execute(from_recovery_list: true)
    end

    it "does not report an attempt to process the assessment onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_attempt)
    end
  end

  context "when deleting documents for real" do
    subject(:use_case_real) do
      described_class.new eav_gateway: eav_database_gateway,
                          queues_gateway:,
                          api_gateway:,
                          documents_gateway: documents_gateway_real,
                          recovery_list_gateway:,
                          audit_logs_gateway:,
                          logger:,
                          assessments_country_id_gateway:,
                          assessment_search_gateway:
    end

    let(:eav_database_gateway) do
      eav_database_gateway = instance_double(Gateway::AssessmentAttributesGateway)
      allow(eav_database_gateway).to receive(:delete_attributes_by_assessment)
      eav_database_gateway
    end
    let(:documents_gateway_real) { Gateway::DocumentsGateway.new }
    let(:assessment_data) do
      {
        "schema_version_original" => "LIG-19.0",
        "sap_version" => 9.94,
        "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
        "calculation_software_version" => "4.05r0005",
        "rrn" => "8570-6826-6530-4969-0202",
        "inspection_date" => "2020-06-01",
        "report_type" => 2,
        "completion_date" => "2020-06-01",
        "registration_date" => "2020-06-01",
        "status" => "entered",
        "language_code" => 1,
        "tenure" => 1,
        "transaction_type" => 1,
        "property_type" => 0,
        "scheme_assessor_id" => "EES/008538",
        "property" =>
          { "address" =>
              { "address_line_1" => "25, Marlborough Place",
                "post_town" => "LONDON",
                "postcode" => "NW8 0PG" },
            "uprn" => 7_435_089_668 },
        "region_code" => 17,
        "country_code" => "EAW",
      }
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

    let(:assessments_country_id_gateway) do
      Gateway::AssessmentsCountryIdGateway.new
    end

    it "successfully deletes the document and the corresponding row from the assessments_country_id" do
      allow(eav_database_gateway).to receive(:delete_attributes_by_assessment).and_return(true)
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000])
      allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3), notForIssueAt: nil })

      documents_gateway_real.add_assessment(assessment_id: "1235-0000-0000-0000-0000", document: assessment_data)
      assessments_country_id_gateway.insert(assessment_id: "1235-0000-0000-0000-0000", country_id: 1)
      use_case_real.execute
      deleted_doc = Gateway::DocumentsGateway::AssessmentDocument.find_by(assessment_id: "1235-0000-0000-0000-0000")
      deleted_assessments_country_id = Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.find_by(assessment_id: "1235-0000-0000-0000-0000")
      expect(deleted_doc).to be_nil
      expect(deleted_assessments_country_id).to be_nil
      expect(audit_logs_gateway).to have_received(:insert_log).with(assessment_id: "1235-0000-0000-0000-0000", event_type: "cancelled", timestamp: anything)
      expect(assessment_search_gateway).to have_received(:delete_assessment).with(assessment_id: "1235-0000-0000-0000-0000")
    end
  end
end
