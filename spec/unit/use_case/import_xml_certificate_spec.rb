describe UseCase::ImportXmlCertificate do
  subject(:use_case) do
    described_class.new(
      import_certificate_data_use_case: import_certificate_data_use_case,
      assessment_attribute_gateway: database_gateway,
      certificate_gateway: certificate_gateway,
      logger: logger,
    )
  end

  let(:database_gateway) do
    Gateway::AssessmentAttributesGateway.new
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
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
    allow(certificate_gateway).to receive(:fetch).and_return(sample)
  end

  context "when transforming the epc xml using the parser" do
    context "when the schema type is known" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: false,
                                                                             createdAt: "2021-07-21T11:26:28.045Z" })
      end

      it "forms together certificate data and passes it into the import certificate data use case" do
        use_case.execute(assessment_id)
        expect(import_certificate_data_use_case).to have_received(:execute).with(
          assessment_id: assessment_id,
          certificate_data: include({
            "calculation_software_version" => "13.05r16",
            "created_at" => "2021-07-21T11:26:28.045Z",
            "schema_type" => "RdSAP-Schema-20.0.0",
            "assessment_type" => "RdSAP",
          }),
        )
      end
    end

    context "when the schema type is not known" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "SAP-Schema-NI-18.0.0",
                                                                             assessmentAddressId: "UPRN-000000000000",
                                                                             typeOfAssessment: "RdSAP",
                                                                             optOut: false,
                                                                             createdAt: "2021-07-21T11:26:28.045Z" })
      end

      it "does not trigger an import" do
        use_case.execute(assessment_id)
        expect(import_certificate_data_use_case).not_to have_received(:execute)
      end
    end
  end

  context "when the certificate gateway is not functioning to return items" do
    before do
      allow(certificate_gateway).to receive(:fetch).and_raise(StandardError)
      use_case.execute(assessment_id)
    end

    it "does not trigger an import" do
      expect(import_certificate_data_use_case).not_to have_received(:execute)
    end

    it "logs out an error" do
      expect(logger).to have_received(:error)
    end
  end
end
