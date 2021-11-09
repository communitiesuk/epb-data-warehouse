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

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "1", attribute_value: {
        "one" => "1",
        "two" => "2",
      }, parent_name: nil)
      # expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "two", attribute_value: "2", parent_name: "1")
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
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "building_parts",
                                                                                        attribute_value: { "building_part" => { "wall" => "brick" } }, parent_name: nil)
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

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "1",
                                                                                        attribute_value: %w[1 2 3], parent_name: nil)
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
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)

      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).with(assessment_id: "0000-0000-0000-0000-0000", attribute_name: "1",
                                                                                        attribute_value: certificate_data["1"], parent_name: nil)
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
      use_case.execute(assessment_id: assessment_id, certificate_data: certificate_data)
      expect(assessment_attributes_gateway).to have_received(:add_attribute_value).exactly(2).times
    end
  end
end
