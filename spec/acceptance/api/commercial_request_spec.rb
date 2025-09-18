require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe "CommercialController" do
  include RSpecDataWarehouseApiServiceMixin

  include_context "when lodging XML"
  include_context "when saving ons data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries
    search_assessment_gateway = Gateway::AssessmentSearchGateway.new
    path = File.join Dir.pwd, "spec/fixtures/json_samples/CEPC-8.0.0/cepc.json"
    cepc = JSON.parse(File.read(path))
    postcode_epc = cepc.merge({ "postcode" => "SW1A 2AA" })
    council_constituency_epc = cepc.merge({ "postcode" => "ML9 9AR" })
    eff_epc = cepc.merge({ "asset_rating" => 35 })
    address_epc = cepc.merge({ "address_line_1" => "2 Banana Street" })
    country_id = 1
    rdsap = parse_assessment(assessment_id: "9999-0000-0000-0000-9996", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "UPRN-100121241798", different_fields: { "postcode" => "SW10 0AA" })

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0000", document: eff_epc, created_at: "2024-01-01", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0001", document: postcode_epc, created_at: "2023-01-01", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0002", document: council_constituency_epc, created_at: "2023-05-05", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0003", document: address_epc, created_at: "2022-05-05", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0003", document: rdsap, created_at: "2022-05-05", country_id:)
  end

  context "when requesting a response from /api/commercial/count" do
    context "when no optional search filters are added" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
        get "/api/commercial/count?date_start=2018-01-01&date_end=2025-01-01"
      end

      it "returns 4 rows of CEPC data" do
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body["data"]["count"]).to eq 4
      end
    end

    context "when optional search filters are added" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
        get "/api/commercial/count?date_start=2018-01-01&date_end=2025-01-01", { eff_rating: %w[A B] }
      end

      it "returns 1 row of data for efficiency rating filter" do
        response_body = JSON.parse(response.body)
        expect(response.status).to eq(200)
        expect(response_body["data"]).to eq({ "count" => 1 })
      end
    end
  end
end
