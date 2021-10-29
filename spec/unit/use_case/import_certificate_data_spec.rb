describe UseCase::ImportCertificateData do
  let(:assessment_attributes_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let!(:use_case) do
    described_class.new(assessment_attribute_gateway: assessment_attributes_gateway)
  end

  before do
    allow(assessment_attributes_gateway).to receive(:add_attribute_value)
  end

  context "when a simple attribute is passed to the usecase" do
    certificate_data = {
      "1" => "A",
      "2" => "B",
    }

    assessment_id = "0000-0000-0000-0000-0000"

    it "passes the attributes and values to the gateway unchanged" do
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "1", attribute_value: "A", parent_name: nil)
      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "2", attribute_value: "B", parent_name: nil)
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
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "one", attribute_value: "1", parent_name: "1")
      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "two", attribute_value: "2", parent_name: "1")
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
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "1", attribute_value: "1|2|3", parent_name: nil)
    end
  end
end
