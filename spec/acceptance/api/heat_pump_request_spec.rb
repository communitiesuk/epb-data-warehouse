require_relative "../../shared_context/shared_lodgement"

describe "HeatPumpController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"

  context "when requesting a response from /api/heat-pump-counts/floor-area" do
    let(:response) do
      header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:read])}")
      get("/api/heat-pump-counts/floor-area")
    end
    let(:type_of_assessment) { "SAP" }
    let(:schema_type) { "SAP-Schema-19.0.0" }
    let(:air_source_description) do
      {
        "description": {
          "value": "Air source heat pump, Underfloor heating and radiators, pipes in screed above insulation, electric",
          "language": "1",
        },
        "energy_efficiency_rating": 5,
        "environmental_efficiency_rating": 5,
      }
    end
    let(:duplicate_ground_source_description) do
      [{ "description": "Ground source heat pump, underfloor, electric", "energy_efficiency_rating": 4, "environmental_efficiency_rating": 5 },
       { "description": "Ground source heat pump, underfloor, electric", "energy_efficiency_rating": 4, "environmental_efficiency_rating": 5 }]
    end

    let(:expected_data) do
      [{ "totalFloorArea" => "BETWEEN 0 AND 50", "numberOfAssessments" => 1 },
       { "totalFloorArea" => "BETWEEN 151 AND 200", "numberOfAssessments" => 1 },
       { "totalFloorArea" => "BETWEEN 51 AND 100", "numberOfAssessments" => 1 }]
    end

    before do
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
    end

    it "returns status 200" do
      expect(response.status).to eq(200)
    end

    it "returns the expected data" do
      response_body = JSON.parse(response.body)
      expect(response_body["data"]).to eq(expected_data)
    end
  end
end
