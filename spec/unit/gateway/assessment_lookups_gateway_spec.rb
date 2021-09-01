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
  end
end
