describe UseCase::ImportXmlCertificate, :set_with_timecop do
  subject(:use_case) do
    described_class.new(
      import_certificate_data_use_case:,
      assessment_attribute_gateway: database_gateway,
      certificate_gateway:,
      recovery_list_gateway:,
      logger:,
      assessments_country_id_gateway:,
    )
  end

  let(:database_gateway) do
    Gateway::AssessmentAttributesGateway.new
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:assessments_country_id_gateway) do
    instance_double(Gateway::AssessmentsCountryIdGateway)
  end

  let(:recovery_list_gateway) do
    gateway = instance_double(Gateway::RecoveryListGateway)
    allow(gateway).to receive(:clear_assessment)
    allow(gateway).to receive(:register_attempt)
    allow(gateway).to receive(:retries_left).and_return(1)
    gateway
  end

  let(:import_certificate_data_use_case) do
    data_use_case = instance_double(UseCase::ImportCertificateData)
    allow(data_use_case).to receive(:execute)
    data_use_case
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  before do
    allow(assessments_country_id_gateway).to receive(:insert)
    allow(certificate_gateway).to receive(:fetch).and_return(sample)
  end

  RSpec::Matchers.define :does_not_contain_key do |key|
    match do |actual|
      !actual.key? key
    end
  end

  context "when transforming the epc xml using the parser" do
    context "when the schema type is known" do
      it "clears the assessment from the recovery list" do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({
          schemaType: "RdSAP-Schema-20.0.0",
          assessmentAddressId: "UPRN-000000000000",
          typeOfAssessment: "RdSAP",
          optOut: false,
          createdAt: "2021-07-21T11:26:28.045Z",
          cancelledAt: "2021-09-05T14:34:56.634Z",
          hashedAssessmentId: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2",
          greenDeal: false,
        })
        use_case.execute(assessment_id)
        expect(recovery_list_gateway).to have_received(:clear_assessment).with(payload: assessment_id, queue: :assessments)
      end

      context "when the certificate is opted out" do
        before do
          allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                               assessmentAddressId: "UPRN-000000000000",
                                                                               typeOfAssessment: "RdSAP",
                                                                               optOut: true,
                                                                               createdAt: "2021-07-21T11:26:28.045Z",
                                                                               cancelledAt: "2021-09-05T14:34:56.634Z",
                                                                               greenDeal: false })
        end

        it "forms together certificate data and passes it into the import certificate data use case" do
          use_case.execute(assessment_id)
          expect(import_certificate_data_use_case).to have_received(:execute).with(
            assessment_id:,
            certificate_data: include({
              "calculation_software_version" => "13.05r16",
              "created_at" => "2021-07-21 11:26:28",
              "cancelled_at" => "2021-09-05 14:34:56",
              "opt_out" => Time.now.utc.strftime("%F %T"),
              "schema_type" => "RdSAP-Schema-20.0.0",
              "assessment_type" => "RdSAP",
            }),
            country_id: nil,
          )
        end
      end

      context "when the certificate is not opted out or cancelled" do
        before do
          allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                               assessmentAddressId: "UPRN-000000000000",
                                                                               typeOfAssessment: "RdSAP",
                                                                               optOut: false,
                                                                               createdAt: "2021-07-21T11:26:28.045Z",
                                                                               greenDeal: false })
          use_case.execute assessment_id
        end

        it "does not produce a data structure containing a cancelled_at key" do
          expect(import_certificate_data_use_case).to have_received(:execute).with(
            assessment_id:,
            certificate_data: match(does_not_contain_key("cancelled_at")),
            country_id: nil,
          )
        end

        it "does not produce a data structure containing an opt_out key" do
          expect(import_certificate_data_use_case).to have_received(:execute).with(
            assessment_id:,
            certificate_data: match(does_not_contain_key("opt_out")),
            country_id: nil,
          )
        end
      end
    end

    context "when the schema type is not known" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "SAP-Schema-Rockall-18.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: false,
                                                                             createdAt: "2021-07-21T11:26:28.045Z" })
        use_case.execute(assessment_id)
      end

      it "does not trigger an import" do
        expect(import_certificate_data_use_case).not_to have_received(:execute)
      end

      it "clears the assessment from the recovery list" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).with(payload: assessment_id, queue: :assessments)
      end
    end

    context "when the createdAt property in the metadata response is null" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: false,
                                                                             createdAt: nil })
        use_case.execute assessment_id
      end

      it "does not produce a data structure containing a created_at key" do
        expect(import_certificate_data_use_case).to have_received(:execute).with(
          assessment_id:,
          certificate_data: match(does_not_contain_key("created_at")),
          country_id: nil,
        )
      end
    end

    context "when the type of assessment is AC-REPORT" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "SAP-Schema-18.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "AC-REPORT",
                                                                             optOut: false,
                                                                             createdAt: "2021-07-21T11:26:28.045Z" })
        use_case.execute(assessment_id)
      end

      it "does not trigger an import" do
        expect(import_certificate_data_use_case).not_to have_received(:execute)
      end

      it "clears the assessment from the recovery list" do
        expect(recovery_list_gateway).to have_received(:clear_assessment).with(payload: assessment_id, queue: :assessments)
      end
    end

    context "when the certificate has a hashed assessment id" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: true,
                                                                             createdAt: "2021-07-21T11:26:28.045Z",
                                                                             cancelledAt: "2021-09-05T14:34:56.634Z",
                                                                             hashedAssessmentId: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2" })
      end

      it "forms together certificate data and passes it into the import certificate data use case" do
        use_case.execute(assessment_id)
        expect(import_certificate_data_use_case).to have_received(:execute).with(
          assessment_id:,
          certificate_data: include({
            "calculation_software_version" => "13.05r16",
            "created_at" => "2021-07-21 11:26:28",
            "cancelled_at" => "2021-09-05 14:34:56",
            "opt_out" => Time.now.utc.strftime("%F %T"),
            "schema_type" => "RdSAP-Schema-20.0.0",
            "assessment_type" => "RdSAP",
            "hashed_assessment_id" => "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2",
          }),
          country_id: nil,
        )
      end
    end

    context "when the certificate has a country_id" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: true,
                                                                             createdAt: "2021-07-21T11:26:28.045Z",
                                                                             cancelledAt: "2021-09-05T14:34:56.634Z",
                                                                             hashedAssessmentId: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2",
                                                                             countryId: 1 })
        use_case.execute(assessment_id)
      end

      it "sends the country_id to the assessments_country_id_gateway" do
        expect(assessments_country_id_gateway).to have_received(:insert).with(assessment_id:, country_id: 1).exactly(1).times
      end
    end

    context "when the certificate has no country_id" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: true,
                                                                             createdAt: "2021-07-21T11:26:28.045Z",
                                                                             cancelledAt: "2021-09-05T14:34:56.634Z",
                                                                             hashedAssessmentId: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2",
                                                                             countryId: nil })
        use_case.execute(assessment_id)
      end

      it "does not send the country_id to the assessments_country_id_gateway" do
        expect(assessments_country_id_gateway).not_to have_received(:insert)
      end
    end

    context "when the certificate is attached to a green deal" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: true,
                                                                             createdAt: "2021-07-21T11:26:28.045Z",
                                                                             cancelledAt: "2021-09-05T14:34:56.634Z",
                                                                             hashedAssessmentId: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2",
                                                                             countryId: nil,
                                                                             greenDeal: true })
        use_case.execute(assessment_id)
      end

      it "does not save the EPC" do
        expect(import_certificate_data_use_case).not_to have_received(:execute)
      end
    end
  end

  context "when the certificate gateway is not functioning to return items" do
    before do
      allow(certificate_gateway).to receive(:fetch).and_raise(StandardError)
      allow(certificate_gateway).to receive(:fetch_meta_data)
      use_case.execute(assessment_id)
    end

    it "does not trigger an import" do
      expect(import_certificate_data_use_case).not_to have_received(:execute)
    end

    it "logs out an error" do
      expect(logger).to have_received(:error).at_least(:once)
    end

    it "does not clear the assessment from the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:clear_assessment)
    end

    it "reports an attempt to process the assessment onto the recovery list" do
      expect(recovery_list_gateway).to have_received(:register_attempt).with(payload: assessment_id, queue: :assessments)
    end
  end

  context "when the certificate gateway has a bad connection to the api" do
    before do
      allow(certificate_gateway).to receive(:fetch).and_raise(Errors::ConnectionApiError)
      allow(certificate_gateway).to receive(:fetch_meta_data)
      use_case.execute(assessment_id)
    end

    it "does not report an attempt to process the assessment onto the recovery list" do
      expect(recovery_list_gateway).not_to have_received(:register_attempt)
    end
  end
end
