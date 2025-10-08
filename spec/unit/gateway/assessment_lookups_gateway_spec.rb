require_relative "../../shared_context/shared_import_enums"

describe Gateway::AssessmentLookupsGateway do
  subject(:gateway) { described_class.new }

  before(:all) do
    import_look_ups(schema_versions: %w[RdSAP-Schema-21.0.1 SAP-Schema-19.0.0/SAP SAP-Schema-19.0.0 SAP-Schema-15.0 RdSAP-Schema-NI-20.0.0])
  end

  include_context "when saving enum data to lookup tables"

  let(:attributes_gateway) { Gateway::AssessmentAttributesGateway.new }
  let(:attribute_id) { attributes_gateway.add_attribute(attribute_name: "my_attribute") }

  describe "#get_lookups_by_attribute_and_key" do
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
    end
  end

  describe "#truncate_tables" do
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

  describe "#fetch_lookups" do
    before do
      import_look_ups(schema_versions: %w[RdSAP-Schema-21.0.1 SAP-Schema-19.0.0/SAP SAP-Schema-19.0.0])
    end

    let(:expected) do
      %w[built_form construction_age_band cylinder_insulation_thickness energy_efficiency_rating energy_tariff glazed_area glazed_type heat_loss_corridor improvement_description improvement_summary main_fuel mechanical_ventilation property_type tenure transaction_type ventilation_type water_heating_fuel]
    end

    it "returns a list of lookups" do
      expect(gateway.fetch_lookups).to eq expected
    end
  end

  describe "#fetch_lookups_values" do
    let(:expected) do
      [{ "key" => "1", "value" => "Detached", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "2", "value" => "Semi-Detached", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "3", "value" => "End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "NR", "value" => "Not Recorded", "schema_version" => "RdSAP-Schema-21.0.1" },
       { "key" => "1", "value" => "Detached", "schema_version" => "SAP-Schema-19.0.0/SAP" },
       { "key" => "2", "value" => "Semi-Detached", "schema_version" => "SAP-Schema-19.0.0/SAP" },
       { "key" => "3", "value" => "End-Terrace", "schema_version" => "SAP-Schema-19.0.0/SAP" },
       { "key" => "4", "value" => "Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0/SAP" },
       { "key" => "5", "value" => "Enclosed End-Terrace", "schema_version" => "SAP-Schema-19.0.0/SAP" },
       { "key" => "6", "value" => "Enclosed Mid-Terrace", "schema_version" => "SAP-Schema-19.0.0/SAP" }]
    end

    context "when filtering by name" do
      let(:results) do
        gateway.fetch_lookups_values(name: "built_form")
      end

      it "returns codes including the schema version" do
        expect(results).to eq expected
      end

      it "include all valid schema versions" do
        expect(results.uniq { |i| i["schema_version"] }.map { |i| i["schema_version"] }).to eq %w[RdSAP-Schema-21.0.1 SAP-Schema-19.0.0/SAP]
      end

      it "returns the correct number of records" do
        expect(results.size).to eq 13
      end

      it "returns the correct number of lookup values for a schema" do
        expect(results.count { |i| i["schema_version"] == "RdSAP-Schema-21.0.1" }).to eq 7
      end
    end

    context "when filtering by name and lookup key" do
      let(:results) do
        gateway.fetch_lookups_values(name: "built_form", lookup_key: "1")
      end

      it "returns the value for a house" do
        expect(results.uniq! { |i| i["value"] }.first["value"]).to eq "Detached"
      end
    end

    context "when filtering by name and lookup key and schema version" do
      let(:results) do
        gateway.fetch_lookups_values(name: "built_form", lookup_key: "NR", schema_version: "RdSAP-Schema-21.0.1")
      end

      it "returns the value for a house" do
        expect(results).to eq [{ "key" => "NR", "value" => "Not Recorded", "schema_version" => "RdSAP-Schema-21.0.1" }]
      end
    end

    context "when filtering for a code that is also in non-domestic" do
      before do
        import_look_ups(schema_versions: %w[CEPC-8.0.0])
      end

      let(:commercial_results) do
        gateway.fetch_lookups_values(name: "transaction_type", schema_version: "CEPC-8.0.0")
      end

      it "returns codes including the schema version" do
        expect(commercial_results.uniq { |i| i["schema_version"] }.map { |i| i["schema_version"] }).to eq ["CEPC-8.0.0"]
      end
    end
  end
end
