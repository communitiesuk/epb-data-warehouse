describe UseCase::ImportCertificateData do
  let(:assessment_attributes_gateway) { instance_double(Gateway::AssessmentAttributesGateway) }
  let(:assessment_id) { "0000-0000-0000-0000-0000" }
  let(:country_id) { 1 }
  let(:documents_gateway) { instance_double(Gateway::DocumentsGateway) }
  let(:assessment_search_gateway) { instance_double(Gateway::AssessmentSearchGateway) }
  let(:commercial_reports_gateway) { instance_double(Gateway::CommercialReportsGateway) }

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let!(:use_case) do
    described_class.new assessment_attribute_gateway: assessment_attributes_gateway,
                        assessment_search_gateway:,
                        commercial_reports_gateway:,
                        documents_gateway:,
                        logger:
  end

  before do
    allow(assessment_attributes_gateway).to receive(:add_attribute_value)
    allow(assessment_attributes_gateway).to receive(:add_attribute_values)
    allow(documents_gateway).to receive(:add_assessment)
    allow(assessment_search_gateway).to receive(:insert_assessment)
    allow(commercial_reports_gateway).to receive(:insert_report)
  end

  context "when importing a domestic certificate" do
    let(:certificate_data) do
      {
        "assessment_type" => "SAP",
        "nested_key" => { "inner" => "data" },
        "array_key" => %w[value1 value2],
      }
    end

    before do
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data, country_id: country_id)
    end

    it "saves the EAV attributes" do
      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("assessment_type", "SAP", nil),
        described_class::AttributeValue.new("nested_key", { "inner" => "data" }, nil),
        described_class::AttributeValue.new("array_key", %w[value1 value2], nil),
        assessment_id:,
      )
    end

    it "saves the document" do
      expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
    end

    it "saves to the search table" do
      expect(assessment_search_gateway).to have_received(:insert_assessment).with(
        {
          assessment_id:,
          country_id:,
          document: certificate_data,
        },
      )
    end

    it "does not save to the commercial reports table" do
      expect(commercial_reports_gateway).not_to have_received(:insert_report)
    end
  end

  context "when the certificate is opted out" do
    context "when it is a domestic certificate" do
      let(:certificate_data) do
        {
          "assessment_type" => "SAP",
          "opt_out" => true,
        }
      end

      before do
        use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data, country_id: country_id)
      end

      it "saves the EAV attributes" do
        expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
          described_class::AttributeValue.new("assessment_type", "SAP", nil),
          described_class::AttributeValue.new("opt_out", true, nil),
          assessment_id:,
        )
      end

      it "saves the document" do
        expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
      end

      it "skips saving to the search table" do
        expect(assessment_search_gateway).not_to have_received(:insert_assessment)
      end

      it "does not save to the commercial reports table" do
        expect(commercial_reports_gateway).not_to have_received(:insert_report)
      end
    end

    context "when it is a non-domestic certificate" do
      let(:certificate_data) do
        {
          "assessment_type" => "CEPC",
          "related_rrn" => "0000-0000-0000-0000-2222",
          "opt_out" => true,
        }
      end

      before do
        use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data, country_id: country_id)
      end

      it "saves the EAV attributes" do
        expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
          described_class::AttributeValue.new("assessment_type", "CEPC", nil),
          described_class::AttributeValue.new("related_rrn", "0000-0000-0000-0000-2222", nil),
          described_class::AttributeValue.new("opt_out", true, nil),
          assessment_id:,
        )
      end

      it "saves the document" do
        expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
      end

      it "skips saving to the search table" do
        expect(assessment_search_gateway).not_to have_received(:insert_assessment)
      end

      it "does not save to the commercial reports table" do
        expect(commercial_reports_gateway).to have_received(:insert_report)
      end
    end
  end

  context "when the attribute gateway raises an error" do
    certificate_data = {
      "bad" => "i am bad",
      "good" => "i am good",
    }

    it "runs the use case without erroring" do
      allow(Sentry).to receive(:capture_exception)
      allow(assessment_attributes_gateway).to receive(:add_attribute_values).and_raise(Boundary::BadAttributesWrite)
      expect { use_case.execute(assessment_id:, certificate_data:) }.not_to raise_error
      expect(Sentry).to have_received(:capture_exception)
    end
  end

  context "when importing a CEPC certificate" do
    let(:certificate_data) do
      {
        "assessment_type" => "CEPC",
        "nested_key" => { "inner" => "data" },
        "related_rrn" => "0000-0000-0000-0000-2222",
      }
    end

    before do
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data, country_id: country_id)
    end

    it "saves the EAV attributes" do
      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("assessment_type", "CEPC", nil),
        described_class::AttributeValue.new("nested_key", { "inner" => "data" }, nil),
        described_class::AttributeValue.new("related_rrn", "0000-0000-0000-0000-2222", nil),
        assessment_id:,
      )
    end

    it "saves the document" do
      expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
    end

    it "saves to the search table" do
      expect(assessment_search_gateway).to have_received(:insert_assessment).with(
        {
          assessment_id:,
          country_id:,
          document: certificate_data,
        },
      )
    end

    it "does save to the commercial reports table" do
      expect(commercial_reports_gateway).to have_received(:insert_report)
    end
  end

  context "when the certificate is a DEC" do
    let(:certificate_data) do
      {
        "assessment_type" => "DEC",
        "nested_key" => { "inner" => "data" },
        "related_rrn" => "0000-0000-0000-0000-2222",
      }
    end

    before do
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data, country_id: country_id)
    end

    it "saves the EAV attributes" do
      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("assessment_type", "DEC", nil),
        described_class::AttributeValue.new("nested_key", { "inner" => "data" }, nil),
        described_class::AttributeValue.new("related_rrn", "0000-0000-0000-0000-2222", nil),
        assessment_id:,
      )
    end

    it "saves the document" do
      expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
    end

    it "saves to the search table" do
      expect(assessment_search_gateway).to have_received(:insert_assessment).with(
        {
          assessment_id:,
          country_id:,
          document: certificate_data,
        },
      )
    end

    it "does save to the commercial reports table" do
      expect(commercial_reports_gateway).to have_received(:insert_report)
    end
  end

  context "when the certificate does not have recommendations" do
    it "does not save data to the commercial reports table" do
      certificate_data = {
        "assessment_type" => "DEC",
      }
      assessment_id = "2222-2222-2222-2222-2222"

      use_case.execute(assessment_id:, certificate_data:)
      expect(commercial_reports_gateway).not_to have_received(:insert_report)
    end
  end
end
