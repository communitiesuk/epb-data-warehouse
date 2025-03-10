require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe "DomesticSearchController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"
  include_context "when saving ons data"

  context "when requesting a response from /api/domestic/count" do
    let(:type_of_assessment) { "SAP" }
    let(:schema_type) { "SAP-Schema-19.0.0" }
    let(:expected_data) do
      { "count" => 3 }
    end

    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
    end

    before do
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, different_fields: { "registration_date": "2023-05-02" })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "ML9 9AR",
        "registration_date": "2023-05-02",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "ML9 9AR",
        "registration_date": "2023-05-02",
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
    end

    context "when the response is a success" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
        get("/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01")
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
end
