describe Gateway::AssessmentLookupsGateway do
  subject(:gateway) { described_class.new }

  let(:attributes_gateway) { Gateway::AssessmentAttributesGateway.new }
  let(:attribute_id) { attributes_gateway.add_attribute(attribute_name: "my_attribute") }

  context "when there is no matching lookup" do
    it "returns an empty array" do
      result = gateway.get_lookups_by_attribute_and_key(
        attribute_id:,
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
        attribute_id:,
        type_of_assessment: "RdSAP",
        attribute_name: "my_attribute",
      )
    end

    before do
      gateway.add_lookup(lookup)
    end

    it "returns the matching lookup" do
      result = gateway.get_lookups_by_attribute_and_key(
        attribute_id:,
        lookup_key: "my_lookup",
      )
      expect(result.first).to eq(lookup)
    end

    describe ".truncate_tables" do
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
          gateway.add_lookup(Domain::AssessmentLookup.new(
                               lookup_key: key,
                               lookup_value: value,
                               attribute_id:,
                               type_of_assessment: "RdSAP",
                               attribute_name: "built_form",
                             ))
          gateway.truncate_tables
        end
      end

      it "returns no records from the database" do
        expect(ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) as cnt FROM assessment_lookups").first["cnt"].to_i).to eq(0)
      end
    end
  end
end
