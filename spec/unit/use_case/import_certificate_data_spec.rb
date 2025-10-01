describe UseCase::ImportCertificateData do
  let(:assessment_attributes_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

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

  context "when a simple attribute is passed to the usecase" do
    certificate_data = {
      "1" => "A",
      "2" => "B",
    }

    country_id = 1

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway unchanged" do
      use_case.execute(assessment_id:, certificate_data:, country_id:)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("1", "A", nil),
        described_class::AttributeValue.new("2", "B", nil),
        assessment_id: "0000-0000-0000-0000-0000",
      )
      expect(assessment_search_gateway).to have_received(:insert_assessment).with(
        {
          assessment_id: "0000-0000-0000-0000-0000",
          country_id: 1,
          document: { "1" => "A", "2" => "B" },
        },
      )
    end
  end

  context "when a nested attribute is passed to the usecase" do
    certificate_data = {
      "1" => {
        "one" => "1",
        "two" => "2",
      },
    }

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway" do
      use_case.execute(assessment_id:, certificate_data:)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("1", { "one" => "1", "two" => "2" }, nil),
        assessment_id: "0000-0000-0000-0000-0000",
      )
    end
  end

  context "when a double nested attribute is passed to the usecase" do
    certificate_data = {
      "building_parts" => {
        "building_part" => { "wall" => "brick" },
      },
    }

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway" do
      use_case.execute(assessment_id:, certificate_data:)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("building_parts", { "building_part" => { "wall" => "brick" } }, nil),
        assessment_id: "0000-0000-0000-0000-0000",
      )
    end
  end

  context "when an array of scalars is passed to the usecase" do
    certificate_data = {
      "1" => %w[
        1
        2
        3
      ],
    }

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway" do
      use_case.execute(assessment_id:, certificate_data:)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("1", %w[1 2 3], nil),
        assessment_id: "0000-0000-0000-0000-0000",
      )
    end
  end

  context "when an array of hashes is passed to the usecase" do
    certificate_data = {
      "1" => [
        { "1a" => "one a" },
        { "1b" => "one b" },
      ],
    }

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway" do
      use_case.execute(assessment_id:, certificate_data:)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("1", certificate_data["1"], nil),
        assessment_id: "0000-0000-0000-0000-0000",
      )
    end

    it "receives the hashes only twice, one for each key" do
      certificate_data = {
        "1" => [
          { "1a" => "one a" },
          { "1b" => "one b" },
        ],
        "2" => [
          { "1a" => "one a" },
          { "1b" => "one b" },
        ],

      }
      use_case.execute(assessment_id:, certificate_data:)
      expect(assessment_attributes_gateway).to have_received(:add_attribute_values).with(
        described_class::AttributeValue.new("1", [{ "1a" => "one a" }, { "1b" => "one b" }], nil),
        described_class::AttributeValue.new("2", [{ "1a" => "one a" }, { "1b" => "one b" }], nil),
        assessment_id:,
      )
    end
  end

  context "when several attributes are passed to the use case and a bad write error is raised" do
    certificate_data = {
      "bad" => "i am bad",
      "good" => "i am good",
    }

    assessment_id = "0000-0000-0001-0000-0000"

    before do
      allow(assessment_attributes_gateway).to receive(:add_attribute_values) do |**_|
        raise Boundary::BadAttributesWrite
      end
    end

    it "runs the use case without erroring" do
      expect { use_case.execute(assessment_id:, certificate_data:) }.not_to raise_error
    end
  end

  context "when attribute data is passed to the use case" do
    assessment_id = "0000-0000-0000-0000-0000"
    certificate_data = {
      "1" => [
        { "1a" => "one a" },
        { "1b" => "one b" },
      ],
      "2" => [
        { "1a" => "one a" },
        { "1b" => "one b" },
      ],
    }

    before do
      use_case.execute(assessment_id:, certificate_data:)
    end

    it "passes the attribute data to the documents gateway for saving" do
      expect(documents_gateway).to have_received(:add_assessment).with(assessment_id:, document: certificate_data)
    end
  end

  context "when passing data to the use case" do
    it "does not save data to the commercial reports table for domestic" do
      certificate_data = {
        "assessment_type" => "SAP",
      }
      assessment_id = "0000-0000-0000-0000-0000"

      use_case.execute(assessment_id:, certificate_data:)

      expect(commercial_reports_gateway).not_to have_received(:insert_report)
    end

    it "saves data to the commercial reports table for CEPC with recommendations" do
      certificate_data = {
        "assessment_type" => "CEPC",
        "related_rrn" => "0000-0000-0000-0000-2222",
      }
      assessment_id = "2222-2222-2222-2222-2222"

      use_case.execute(assessment_id:, certificate_data:)
      expect(commercial_reports_gateway).to have_received(:insert_report).with(assessment_id:, related_rrn: "0000-0000-0000-0000-2222")
    end
  end
end
