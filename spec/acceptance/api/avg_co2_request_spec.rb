require_relative "../../shared_context/shared_lodgement"

describe "ReportingController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"

  context "when requesting a response from /api/avg-co2-emissions" do
    let(:expected_data) do
      { "all" => [{ "avgCo2Emission" => 10, "yearMonth" => "2022-05", "assessmentType" => "SAP" },
                  { "avgCo2Emission" => 10, "yearMonth" => "2022-03", "assessmentType" => "SAP" }],
        "northernIreland" => [{ "avgCo2Emission" => 10, "country" => "Northern Ireland", "yearMonth" => "2022-03", "assessmentType" => "SAP" }],
        "england" => [{ "avgCo2Emission" => 10, "country" => "England", "yearMonth" => "2022-05", "assessmentType" => "SAP" }] }
    end

    before do
      type_of_assessment = "SAP"
      schema_type = "SAP-Schema-19.0.0"
      add_countries
      add_assessment(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, different_fields: {
        "co2_emissions_current_per_floor_area": 5,
      })
      add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
        "co2_emissions_current_per_floor_area": 10,
      })
      add_assessment(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
        "co2_emissions_current_per_floor_area": 15,
      })
      add_assessment(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment:, different_fields: {
        "co2_emissions_current_per_floor_area": 10,
        "postcode" => "BT1 1AA",
        "registration_date": "2022-03-01",
      })

      ActiveRecord::Base.connection.exec_query("REFRESH MATERIALIZED VIEW mvw_avg_co2_emissions", "SQL")
    end

    context "when a request is successful" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:read])}")
        get("/api/avg-co2-emissions")
      end

      it "returns status 200" do
        expect(response.status).to eq(200)
      end

      it "returns the expected data" do
        response_body = JSON.parse(response.body)
        expect(response_body["data"].sort).to eq(expected_data.sort)
      end
    end
  end
end
