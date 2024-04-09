require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require "csv"

describe Gateway::ExportHeatPumpsGateway do
  subject(:gateway) { described_class.new }

  include_context "when lodging XML"
  include_context "when saving ons data"

  before(:all) do
    type_of_assessment = "SAP"
    schema_type = "SAP-Schema-19.0.0"

    air_source_description = [{
      "description": {
        "value": "Air source heat pump, Underfloor heating and radiators, pipes in screed above insulation, electric",
        "language": "1",
      },
      "energy_efficiency_rating": 5,
      "environmental_efficiency_rating": 5,
    }]
    duplicate_ground_source_description = [{ "description": "Ground source heat pump, underfloor, electric", "energy_efficiency_rating": 4, "environmental_efficiency_rating": 5 },
                                           { "description": "Ground source heat pump, underfloor, electric", "energy_efficiency_rating": 4, "environmental_efficiency_rating": 5 }]
    welsh_ground_source_description = [{
      "description": {
        "value": "Pwmp gwres tarddu yn y ddaear, rheiddiaduron, trydan",
        "language": "2",
      },
      "energy_efficiency_rating": 5,
      "environmental_efficiency_rating": 5,
    }]
    air_source_second_description = [
      { "description": { "value": "Community scheme", "language": "1" }, "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
      { "description": "Air source heat pump, fan coil units, electric", "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
    ]
    welsh_air_source_description = [{ "description": "Pwmp gwres tarddu yn yr awyr, dan y llawr, trydan}",
                                      "energy_efficiency_rating": 4,
                                      "environmental_efficiency_rating": 5 }]
    mixed_exhaust_air_source_description = [
      { "description": { "value": "Mixed exhaust air source heat pump, Underfloor heating, pipes in screed above insulation, electric", "language": "1" },
        "energy_efficiency_rating": 5,
        "environmental_efficiency_rating": 5 },
    ]
    exhaust_air_mev_source_description = [{ "description": { "value": "Exhaust air MEV source heat pump, Underfloor heating, pipes in screed above insulation, electric", "language": "1" },
                                            "energy_efficiency_rating": 4,
                                            "environmental_efficiency_rating": 5 }]
    water_source_description = [
      { "description": "Water source heat pump, underfloor, electric", "energy_efficiency_rating": 2, "environmental_efficiency_rating": 3 },
    ]
    solar_description = [
      { "description": "Solar assisted source heat pump, Underfloor heating and radiators, pipes in screed above insulation, electric", "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
    ]
    electric_description = [{ "description": "Electric heat pumps, electric",
                              "energy_efficiency_rating": 2,
                              "environmental_efficiency_rating": 3 }]
    community_description = [{ "description": { "value": "Community heat pump, underfloor, Heat pump", "language": "1" },
                               "energy_efficiency_rating": 3,
                               "environmental_efficiency_rating": 4 }]
    exhaust_air_source = [{ "description": { "value": "Exhaust source heat pump, Fan coil units, electric", "language": "1" },
                            "energy_efficiency_rating": 5,
                            "environmental_efficiency_rating": 5 }]
    air_and_ground_source = [{ "description": { "value": "Ground source heat pump, underfloor, electric", "language": "1" }, "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
                             { "description": "Air source heat pump, warm air, electric", "energy_efficiency_rating": 2, "environmental_efficiency_rating": 4 }]

    import_postcode_directory_name
    import_postcode_directory_data
    import_enums "spec/config/attribute_enum_property_type.json"
    add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:)
    add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": air_source_description,
      "total_floor_area": 34,
      "postcode": "ML9 9AR",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": duplicate_ground_source_description,
      "property_type": 1,
      "total_floor_area": 59,
      "postcode": "ML9 9AR",
    })
    add_commercial_assessment
    add_ni_assessment(assessment_id: "0000-0000-0000-0000-0004", different_fields: {
      "postcode": "ML9 9AR",
    })
    add_non_new_dwelling_sap(assessment_id: "0000-0000-0000-0000-0005")
    add_assessment_out_of_date_range(assessment_id: "0000-0000-0000-0000-0006")
    add_assessment(assessment_id: "0000-0000-0000-0000-0007", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": welsh_ground_source_description,
      "total_floor_area": 101,
      "postcode": "SW10 0AA",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0008", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": air_source_second_description,
      "total_floor_area": 251,
      "postcode": "SW10 0AA",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": welsh_air_source_description,
      "property_type": 2,
      "total_floor_area": 208,
      "postcode": "W6 9ZD",
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0010", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": mixed_exhaust_air_source_description,
      "property_type": 3,
      "total_floor_area": 122,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0011", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": exhaust_air_mev_source_description,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0012", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": water_source_description,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0013", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": solar_description,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0014", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": electric_description,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0015", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": community_description,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0016", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": exhaust_air_source,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0017", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": air_and_ground_source,
    })
  end

  before do
    allow($stdout).to receive(:puts)
  end

  describe "#fetch_by_property_type" do
    let(:expected_values) do
      [{ "property_type" => "House", "number_of_assessments" => 11 },
       { "property_type" => "Bungalow", "number_of_assessments" => 1 },
       { "property_type" => "Flat", "number_of_assessments" => 1 },
       { "property_type" => "Maisonette", "number_of_assessments" => 1 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_property_type(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_floor_area" do
    let(:expected_values) do
      [{ "total_floor_area" => "BETWEEN 0 AND 50", "number_of_assessments" => 1 },
       { "total_floor_area" => "BETWEEN 101 AND 150", "number_of_assessments" => 2 },
       { "total_floor_area" => "BETWEEN 151 AND 200", "number_of_assessments" => 8 },
       { "total_floor_area" => "BETWEEN 201 AND 250", "number_of_assessments" => 1 },
       { "total_floor_area" => "BETWEEN 51 AND 100", "number_of_assessments" => 1 },
       { "total_floor_area" => "GREATER THAN 251", "number_of_assessments" => 1 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_floor_area(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_local_authority" do
    include_context "when saving ons data"

    let(:expected_values) do
      [{ "local_authority" => nil,
         "number_of_assessments" => 9 },
       { "local_authority" => "South Lanarkshire",
         "number_of_assessments" => 2 },
       { "local_authority" => "Hammersmith and Fulham",
         "number_of_assessments" => 3 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_local_authority(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_parliamentary_constituency" do
    let(:expected_values) do
      [{ "number_of_assessments" => 3, "westminster_parliamentary_constituency" => "Chelsea and Fulham" },
       { "number_of_assessments" => 2, "westminster_parliamentary_constituency" => "Lanark and Hamilton East" },
       { "number_of_assessments" => 9, "westminster_parliamentary_constituency" => nil }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_parliamentary_constituency(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_description" do
    let(:expected_values) do
      [{ "heat_pump_description" => "Mixed exhaust air source heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Exhaust air MEV source heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Ground source heat pump", "number_of_assessments" => 4 },
       { "heat_pump_description" => "Water source heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Solar assisted heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Electric heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Community heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Exhaust source heat pump", "number_of_assessments" => 1 },
       { "heat_pump_description" => "Air source heat pump", "number_of_assessments" => 4 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_description(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end
end
