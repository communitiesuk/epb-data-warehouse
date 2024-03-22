require_relative "../../shared_context/shared_lodgement"

describe Gateway::ExportHeatPumpsGateway do
  subject(:gateway) { described_class.new }

  include_context "when lodging XML"

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:schema_type) { "SAP-Schema-19.0.0" }

  before do
    allow($stdout).to receive(:puts)
    get_task("import_enums_xsd").invoke("spec/config/attribute_enum_property_type.json")
    add_assessment(assessment_id:, schema_type:, type_of_assessment: "SAP")
    add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment: "SAP", different_fields: {
      "main_heating": [
        {
          "description": {
            "value": "Air source heat pump, Underfloor heating and radiators, pipes in screed above insulation, electric",
            "language": "1",
          },
          "energy_efficiency_rating": 5,
          "environmental_efficiency_rating": 5,
        },
      ],
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment: "SAP", different_fields: {
      "property_type": 1,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc")
    add_assessment(assessment_id: "0000-0000-0000-0000-0004", schema_type: "SAP-Schema-NI-18.0.0", type_of_assessment: "SAP")
    add_assessment(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment: "SAP", different_fields: {
      "transaction_type": 1,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0006", schema_type:, type_of_assessment: "SAP", different_fields: {
      "registration_date": "2023-01-08",
    })
  end

  describe "#fetch_by_property_type" do
    let(:expected_values) { [{ "property_type" => "House", "count" => 2 }, { "property_type" => "Bungalow", "count" => 1 }].sort_by! { |k| k["count"] } }

    it "has the expected values" do
      expect(gateway.fetch_by_property_type(start_date: "2022-05-01", end_date: "2022-05-31")).to eq expected_values
    end
  end
end
