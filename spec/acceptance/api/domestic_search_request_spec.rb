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
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment:, different_fields: {
        "registration_date": "2023-05-02",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "SW1V 2AA",
        "registration_date": "2023-05-02",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "SW1V 2AA",
        "energy_rating_current": 50,
        "registration_date": "2023-05-02",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment:, different_fields: {
        "postcode": "SW1X JBA",
        "energy_rating_current": 83,
        "registration_date": "2023-05-02",
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
    end

    context "when the response is a success" do
      context "when no optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01"
        end

        it "returns 4 rows of data" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq({ "count" => 4 })
        end
      end

      context "when optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01", { eff_rating: %w[B E] }
        end

        it "returns 2 rows of data for efficiency rating filter" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq({ "count" => 2 })
        end
      end
    end

    context "when using a wrong token" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:read])}")
        get("/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01")
      end

      it "returns status 403" do
        expect(response.status).to eq(403)
      end

      it "raises an error due to the missing token" do
        expect(response.body).to include "You are not authorised to perform this request"
      end
    end
  end
end
