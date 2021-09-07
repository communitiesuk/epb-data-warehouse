describe Gateway::AssessmentLookupsGateway do

  subject(:gateway) { described_class.new }

  let(:attributes_gateway) { Gateway::AssessmentAttributesGateway.new }
  let(:attribute_id) { attributes_gateway.add_attribute(attribute_name: "my_attribute") }

  context "when there is no matching lookup" do
    it "returns an empty array" do
      result = gateway.get_lookups_by_attribute_and_key(
        attribute_id: attribute_id,
        lookup_key: "my_lookup",
      )
      expect(result).to be_empty
    end
  end

  context "when there is a matching lookup" do
    let(:lookup) do
      Domain::AssessmentLookup.new(
        lookup_key: "my_lookup",
        lookup_value: "my_value",
        attribute_id: attribute_id,
        type_of_assessment: "RdSAP",
      )
    end

    before do
      gateway.add_lookup(lookup)
    end

    it "returns the matching lookup" do
      result = gateway.get_lookups_by_attribute_and_key(
        attribute_id: attribute_id,
        lookup_key: "my_lookup",
      )
      expect(result.first).to eq(lookup)
    end

    describe ".get_value_by_key" do
      before do
        enum = {
          "1" => "Detached",
          "2" => "Semi-Detached",
          "3" => "End-Terrace",
          "4" => "Mid-Terrace",
          "5" => "Enclosed End-Terrace",
          "6" => "Enclosed Mid-Terrace",
          "NR" => "Not Recorded",
        }.freeze
        assessment_attribute = Gateway::AssessmentAttributesGateway.new
        attribute_id = assessment_attribute.add_attribute(attribute_name: "built_form")
        enum.each do |key, value|
          gateway.add_lookup( Domain::AssessmentLookup.new(
            lookup_key: key,
            lookup_value: value,
            attribute_id: attribute_id,
            type_of_assessment: "RdSAP",
            ))
        end
      end

      it "returns the string representation of teh value stored in the orginal xml " do
        expect(gateway.get_value_by_key(attribute_name: "built_form", lookup_key: "1")).to eq("Detached")
      end
    end
  end
end
