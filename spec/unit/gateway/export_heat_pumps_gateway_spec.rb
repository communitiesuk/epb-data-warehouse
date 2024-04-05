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
      "total_floor_area": 34,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment: "SAP", different_fields: {
      "property_type": 1,
      "total_floor_area": 59,
    })
    add_commercial_assessment
    add_ni_assessment
    add_non_new_dwelling_sap
    add_assessment_out_of_date_range
    add_assessment(assessment_id: "0000-0000-0000-0000-0007", schema_type:, type_of_assessment: "SAP", different_fields: {
      "main_heating": [
        {
          "description": {
            "value": "Pwmp gwres tarddu yn y ddaear, rheiddiaduron, trydan",
            "language": "2",
          },
          "energy_efficiency_rating": 5,
          "environmental_efficiency_rating": 5,
        },
      ],
      "total_floor_area": 101,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0008", schema_type:, type_of_assessment: "SAP", different_fields: {
      "main_heating": [
        { "description": "Room heaters, wood logs", "energy_efficiency_rating": 2, "environmental_efficiency_rating": 5 },
        { "description": "Air source heat pump, fan coil units, electric", "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
      ],
      "total_floor_area": 251,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment: "SAP", different_fields: {
      "property_type": 2,
      "total_floor_area": 208,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0010", schema_type:, type_of_assessment: "SAP", different_fields: {
      "property_type": 3,
      "total_floor_area": 122,
    })
  end

  describe "#fetch_by_property_type" do
    let(:expected_values) do
      [{ "property_type" => "House", "count" => 4 },
       { "property_type" => "Bungalow", "count" => 1 },
       { "property_type" => "Flat", "count" => 1 },
       { "property_type" => "Maisonette", "count" => 1 }].sort_by! { |k| k["property_type"] }
    end

    it "has the expected values" do
      expect(gateway.fetch_by_property_type(start_date: "2022-05-01", end_date: "2022-05-31")).to eq expected_values
    end
  end

  describe "#fetch_by_total_floor_area" do
    let(:expected_values) do
      [{ "total_floor_area" => "BETWEEN 0 AND 50", "count" => 1 },
       { "total_floor_area" => "BETWEEN 101 AND 150", "count" => 2 },
       { "total_floor_area" => "BETWEEN 151 AND 200", "count" => 1 },
       { "total_floor_area" => "BETWEEN 201 AND 250", "count" => 1 },
       { "total_floor_area" => "BETWEEN 51 AND 100", "count" => 1 },
       { "total_floor_area" => "GREATER THAN 251", "count" => 1 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_total_floor_area(start_date: "2022-05-01", end_date: "2022-05-31")).to eq expected_values
    end
  end
end
