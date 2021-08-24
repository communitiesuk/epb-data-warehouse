describe Gateway::AssessmentLookUpsGateway do
  subject(:gateway) { described_class.new }

  context "when there is no matching lookup" do
    it "returns an empty array" do
      result = gateway.get_lookups_by_attribute_and_name(
        attribute_id: 1,
        look_up_name: "my_lookup",
      )
      expect(result).to be_empty
    end
  end

  context "when there is a matching lookup" do
    let(:lookup) do
      Domain::AssessmentLookup.new(
        lookup_key: "my_lookup",
        lookup_value: "my_value",
        attribute_id: 1,
        schema: "RdSAP",
      )
    end

    before { gateway.add_lookup(lookup) }

    it "returns the matching lookup" do
      result = gateway.get_lookups_by_attribute_and_name(
        attribute_id: 1,
        look_up_name: "my_lookup",
      )
      expect(result.first).to eq(lookup)
    end
  end
end
