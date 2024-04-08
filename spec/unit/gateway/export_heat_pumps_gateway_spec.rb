require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require "csv"

describe Gateway::ExportHeatPumpsGateway do
  subject(:gateway) { described_class.new }

  include_context "when lodging XML"
  include_context "when saving ons data"

  let(:schema_type) do
    "SAP-Schema-19.0.0"
  end

  let(:seed_data) do
    true
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    import_enums "spec/config/attribute_enum_property_type.json"
  end

  before do
    allow($stdout).to receive(:puts)
    type_of_assessment = "SAP"
    add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:)
    add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
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
    add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
      "property_type": 1,
      "total_floor_area": 59,
    })
    add_commercial_assessment
    add_ni_assessment
    add_non_new_dwelling_sap
    add_assessment_out_of_date_range
    add_assessment(assessment_id: "0000-0000-0000-0000-0007", schema_type:, type_of_assessment:, different_fields: {
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
    add_assessment(assessment_id: "0000-0000-0000-0000-0008", schema_type:, type_of_assessment:, different_fields: {
      "main_heating": [
        { "description": "Room heaters, wood logs", "energy_efficiency_rating": 2, "environmental_efficiency_rating": 5 },
        { "description": "Air source heat pump, fan coil units, electric", "energy_efficiency_rating": 5, "environmental_efficiency_rating": 5 },
      ],
      "total_floor_area": 251,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment:, different_fields: {
      "property_type": 2,
      "total_floor_area": 208,
    })
    add_assessment(assessment_id: "0000-0000-0000-0000-0010", schema_type:, type_of_assessment:, different_fields: {
      "property_type": 3,
      "total_floor_area": 122,
    })
  end

  describe "#fetch_by_property_type" do
    let(:expected_values) do
      [{ "property_type" => "House", "count" => 4 },
       { "property_type" => "Bungalow", "count" => 1 },
       { "property_type" => "Flat", "count" => 1 },
       { "property_type" => "Maisonette", "count" => 1 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_property_type(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_floor_area" do
    let(:expected_values) do
      [{ "total_floor_area" => "BETWEEN 0 AND 50", "count" => 1 },
       { "total_floor_area" => "BETWEEN 101 AND 150", "count" => 2 },
       { "total_floor_area" => "BETWEEN 151 AND 200", "count" => 1 },
       { "total_floor_area" => "BETWEEN 201 AND 250", "count" => 1 },
       { "total_floor_area" => "BETWEEN 51 AND 100", "count" => 1 },
       { "total_floor_area" => "GREATER THAN 251", "count" => 1 }]
    end

    it "has the expected values" do
      expect(gateway.fetch_by_floor_area(start_date: "2022-05-01", end_date: "2022-05-31")).to eq expected_values
    end
  end

  describe "#fetch_by_local_authority" do
    include_context "when saving ons data"

    let(:expected_values) do
      [{ "local_authority" => nil,
         "number_of_assessments" => 2 },
       { "local_authority" => "South Lanarkshire",
         "number_of_assessments" => 2 },
       { "local_authority" => "Hammersmith and Fulham",
         "number_of_assessments" => 3 }]
    end

    before do
      update_postcode("0000-0000-0000-0000-0001", "ML9 9AR")
      update_postcode("0000-0000-0000-0000-0002", "ML9 9AR")
      update_postcode("0000-0000-0000-0000-0004", "BT10 0AA")
      update_postcode("0000-0000-0000-0000-0007", "SW10 0AA")
      update_postcode("0000-0000-0000-0000-0008", "SW10 0AA")
      update_postcode("0000-0000-0000-0000-0009", "W6 9ZD")
    end

    it "has the expected values" do
      expect(gateway.fetch_by_local_authority(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end

  describe "#fetch_by_parliamentary_constituency" do
    let(:expected_values) do
      [{ "number_of_assessments" => 3, "westminster_parliamentary_constituency" => "Chelsea and Fulham" },
       { "number_of_assessments" => 2, "westminster_parliamentary_constituency" => "Lanark and Hamilton East" },
       { "number_of_assessments" => 2, "westminster_parliamentary_constituency" => nil }]
    end

    before do
      update_postcode("0000-0000-0000-0000-0001", "ML9 9AR")
      update_postcode("0000-0000-0000-0000-0002", "ML9 9AR")
      update_postcode("0000-0000-0000-0000-0004", "BT10 0AA")
      update_postcode("0000-0000-0000-0000-0007", "SW10 0AA")
      update_postcode("0000-0000-0000-0000-0008", "SW10 0AA")
      update_postcode("0000-0000-0000-0000-0009", "W6 9ZD")
    end

    it "has the expected values" do
      expect(gateway.fetch_by_parliamentary_constituency(start_date: "2022-05-01", end_date: "2022-05-31") - expected_values).to eq []
    end
  end
end
