require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"

describe "DomesticSearchController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"
  include_context "when saving ons data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries

    search_assessment_gateway = Gateway::AssessmentSearchGateway.new
    rdsap = parse_assessment(assessment_id: "9999-0000-0000-0000-9996", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", assessment_address_id: "UPRN-100121241798", different_fields: { "postcode" => "SW10 0AA" })
    sap = parse_assessment(assessment_id: "9999-0000-0000-0000-9995", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", assessment_address_id: "UPRN-100121241799", different_fields: { "postcode" => "SW10 0AA", "energy_rating_current" => 72 })

    postcode_rdsap = rdsap.merge({ "postcode" => "SW1A 2AA" })
    council_constituency_rdsap = rdsap.merge({ "postcode" => "ML9 9AR" })
    eff_rdsap = rdsap.merge({ "energy_rating_current" => 85 })
    address_rdsap = rdsap.merge({ "address_line_1" => "2 Banana Street" })
    country_id = 1

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_search;")
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0000", document: eff_rdsap, created_at: "2024-01-01", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0001", document: postcode_rdsap, created_at: "2023-01-01", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0002", document: council_constituency_rdsap, created_at: "2023-05-05", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0003", document: address_rdsap, created_at: "2022-05-05", country_id:)
    search_assessment_gateway.insert_assessment(assessment_id: "0000-0000-0000-0004", document: sap, created_at: "2022-01-01", country_id: 1)
  end

  context "when requesting a response from /api/domestic/count" do
    context "when the response is a success" do
      context "when no optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01"
        end

        it "returns 4 rows of data" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq({ "count" => 5 })
        end
      end

      context "when optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/count?date_start=2018-01-01&date_end=2025-01-01", { eff_rating: %w[A B] }
        end

        it "returns 1 row of data for efficiency rating filter" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq({ "count" => 1 })
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

  context "when requesting a response from /api/domestic/search" do
    let(:expected_data) do
      {
        "addressLine1" => "1 Some Street",
        "addressLine2" => nil,
        "addressLine3" => nil,
        "addressLine4" => nil,
        "buildingReferenceNumber" => "100121241798",
        "certificateNumber" => "0000-0000-0000-0000",
        "constituency" => "Chelsea and Fulham",
        "council" => "Hammersmith and Fulham",
        "currentEnergyEfficiencyBand" => "B",
        "postTown" => "Whitbury",
        "postcode" => "SW10 0AA",
        "registrationDate" => "2020-05-04T00:00:00.000Z",
      }
    end

    context "when the response is a success" do
      context "when no optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01"
        end

        it "returns a successful response with data" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 5
        end

        it "returns expected data" do
          response_body = JSON.parse(response.body)
          result = response_body["data"].find { |i| i["certificateNumber"] == "0000-0000-0000-0000" }
          expect(result).to eq expected_data
        end

        it "includes pagination data" do
          response_body = JSON.parse(response.body)
          expected_pagination = {
            "totalRecords" => 5,
            "currentPage" => 1,
            "totalPages" => 1,
            "nextPage" => nil,
            "prevPage" => nil,
          }
          expect(response_body["pagination"]).to eq(expected_pagination)
        end
      end

      context "when optional postcode filter is added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { postcode: "SW1A 2AA" }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0001")
        end
      end

      context "when optional council filter is added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { council: ["South Lanarkshire"] }
        end

        let(:multiple_responses) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { council: ["South Lanarkshire", "Hammersmith and Fulham"] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0002")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when optional constituency filter is added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { constituency: ["Lanark and Hamilton East"] }
        end

        let(:multiple_responses) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { constituency: ["Lanark and Hamilton East", "Chelsea and Fulham"] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0002")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when optional eff_rating filter is added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { eff_rating: %w[B] }
        end

        let(:multiple_responses) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { eff_rating: %w[B E] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when optional address filter is added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2025-01-01", { address: "2 Banana Street" }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0003")
        end
      end
    end

    context "when getting an error response" do
      context "when dates are missing" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search"
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the missing dates" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please provide a valid date range"
        end
      end

      context "when dates are out of range" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2025-01-01&date_end=2018-01-01"
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the invalid date range" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please provide a valid date range"
        end
      end

      context "when date range includes today" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          tomorrow = Date.tomorrow.strftime "%Y-%m-%d"
          get "/api/domestic/search?date_start=2014-01-01", { date_end: tomorrow }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the date range including today" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "the date cannot include today"
        end
      end

      context "when no results found" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2018-01-01&date_end=2018-02-01"
        end

        it "returns 404" do
          expect(response.status).to eq(404)
        end

        it "raises an error for no results found" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "No domestic assessments could be found for that query"
        end
      end

      context "when postcode is invalid" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2018-01-01", { postcode: "invalid postcode" }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the invalid postcode" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please prove a valid postcode"
        end
      end

      context "when council is invalid" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2018-01-01", { council: ["invalid council"] }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the council name not found" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "provide valid council name(s)"
        end
      end

      context "when constituency is invalid" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2018-01-01", { constituency: ["invalid constituency"] }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the constituency name not found" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "provide valid constituency name(s)"
        end
      end

      context "when current_page is negative" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: -1 }
        end

        it "returns 416" do
          expect(response.status).to eq(416)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number -1 is out of range. Please provide a page number between 1 and 1"
        end
      end

      context "when current_page is zero" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: 0 }
        end

        it "returns 416" do
          expect(response.status).to eq(416)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number 0 is out of range. Please provide a page number between 1 and 1"
        end
      end

      context "when current_page is not a number" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/domestic/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: "not-a-number" }
        end

        it "returns 416" do
          expect(response.status).to eq(416)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number 0 is out of range. Please provide a page number between 1 and 1"
        end
      end
    end
  end
end
