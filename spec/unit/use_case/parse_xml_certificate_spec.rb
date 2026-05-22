describe UseCase::ParseXmlCertificate do
  subject(:use_case) { described_class.new }

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:schema_type) { "RdSAP-Schema-20.0.0" }

  let(:sample) do
    Samples.xml(schema_type)
  end

  shared_examples "test parse" do |use_subprocess:|
    it "parses out XML into a hash" do
      expect(use_case.execute(xml: sample, schema_type:, assessment_id:, use_subprocess:)).to include(
        "country_code" => "EAW",
        "region_code" => 1,
      )
    end
  end

  context "when using subprocess" do
    include_examples "test parse", use_subprocess: true
  end

  context "when not using subprocess" do
    include_examples "test parse", use_subprocess: false
  end

  context "when using a schema type that is not parsed" do
    it "returns nil" do
      expect(use_case.execute(xml: sample, schema_type: "SAP-Schema-10.1", assessment_id:)).to be_nil
    end
  end

  context "when the parsed XML contains string values with whitespaces or newlines" do
    shared_examples "strips whitespace or newlines" do |use_subprocess:|
      context "when a top-level string field has embedded and surrounding whitespaces and newlines" do
        let(:xml_with_whitespace) do
          sample.gsub(
            "<Calculation-Software-Name>SomeSoft RdSAP Calculator</Calculation-Software-Name>",
            "<Calculation-Software-Name>\n  SomeSoft\n      RdSAP Calculator\n  </Calculation-Software-Name>",
          )
        end

        it "strips the string value" do
          result = use_case.execute(xml: xml_with_whitespace, schema_type:, assessment_id:, use_subprocess:)
          expect(result["calculation_software_name"]).to eq("SomeSoft RdSAP Calculator")
        end
      end

      context "when a string inside a nested hash has embedded whitespace and newlines" do
        let(:xml_with_whitespace) do
          sample.gsub(
            "<Address-Line-1>1 Some Street</Address-Line-1>",
            "<Address-Line-1>\n  1\n      Some Street\n  </Address-Line-1>",
          )
        end

        it "strips the string value inside the nested hash" do
          result = use_case.execute(xml: xml_with_whitespace, schema_type:, assessment_id:, use_subprocess:)
          expect(result["address_line_1"]).to eq("1 Some Street")
        end
      end

      context "when a string inside an array element has embedded whitespace and newlines" do
        let(:xml_with_whitespace) do
          sample.gsub(
            "<Description>Solid brick, as built, no insulation (assumed)</Description>",
            "<Description>\n  Solid brick,\n      as built, no insulation (assumed)\n  </Description>",
          )
        end

        it "strips the string value inside the array element" do
          result = use_case.execute(xml: xml_with_whitespace, schema_type:, assessment_id:, use_subprocess:)
          expect(result["walls"].first["description"]).to eq("Solid brick, as built, no insulation (assumed)")
        end
      end

      context "when the parsed result contains non-string values" do
        it "leaves floats unchanged" do
          result = use_case.execute(xml: sample, schema_type:, assessment_id:, use_subprocess:)
          expect(result["sap_version"]).to eq(9.8)
        end

        it "leaves integers unchanged" do
          result = use_case.execute(xml: sample, schema_type:, assessment_id:, use_subprocess:)
          expect(result["region_code"]).to eq(1)
        end

        it "leaves integer values inside array elements unchanged" do
          result = use_case.execute(xml: sample, schema_type:, assessment_id:, use_subprocess:)
          expect(result["walls"].first["energy_efficiency_rating"]).to eq(1)
        end
      end
    end

    context "when using subprocess" do
      include_examples "strips whitespace or newlines", use_subprocess: true
    end

    context "when not using subprocess" do
      include_examples "strips whitespace or newlines", use_subprocess: false
    end
  end
end
