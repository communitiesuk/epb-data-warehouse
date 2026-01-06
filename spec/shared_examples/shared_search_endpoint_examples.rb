shared_examples "a search API endpoint" do |type:|
  context "when requesting a response from /api/#{type}/search" do
    let(:expected_data) do
      if type == "domestic"
        {
          "addressLine1" => "1 Some Street",
          "addressLine2" => nil,
          "addressLine3" => nil,
          "addressLine4" => nil,
          "certificateNumber" => "0000-0000-0000-0000-0000",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "currentEnergyEfficiencyBand" => "B",
          "postTown" => "Whitbury",
          "postcode" => "SW10 0AA",
          "uprn" => 100_121_241_798,
          "registrationDate" => "2020-05-04",
        }
      elsif type == "non-domestic"
        {
          "addressLine1" => "60 Maple Syrup Road",
          "addressLine2" => "Candy Mountain",
          "addressLine3" => nil,
          "addressLine4" => nil,
          "certificateNumber" => "0000-0000-0000-0000-0000",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "currentEnergyEfficiencyBand" => "B",
          "postTown" => "Big Rock",
          "postcode" => "SW10 0AA",
          "registrationDate" => "2021-03-19",
          "uprn" => 100_121_241_798,
          "relatedRrn" => "0000-0000-0000-0000-1111",
        }
      else
        {
          "addressLine1" => "Swim & Fitness Centre",
          "addressLine2" => "Swimming Lane",
          "addressLine3" => nil,
          "addressLine4" => nil,
          "certificateNumber" => "0000-0000-0000-0000-0000",
          "constituency" => "Chelsea and Fulham",
          "council" => "Hammersmith and Fulham",
          "currentEnergyEfficiencyBand" => "B",
          "postTown" => "Floatering",
          "postcode" => "SW10 0AA",
          "registrationDate" => "2021-10-12",
          "uprn" => 100_121_241_798,
        }
      end
    end

    before do
      stub_bearer_token_access
    end

    context "when the response is a success" do
      context "when the date range is passed" do
        let(:response) do
          get "/api/#{type}/search?date_start=2018-01-01&date_end=2025-01-01"
        end

        let(:expected_pagination) do
          {
            "totalRecords" => 5,
            "currentPage" => 1,
            "totalPages" => 1,
            "nextPage" => nil,
            "prevPage" => nil,
            "pageSize" => 5000,
          }
        end

        it "returns a successful response with data" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 5
        end

        it "returns expected data" do
          response_body = JSON.parse(response.body)
          result = response_body["data"].find { |i| i["certificateNumber"] == "0000-0000-0000-0000-0000" }
          expect(result).to eq expected_data
        end

        it "includes pagination data" do
          response_body = JSON.parse(response.body)
          expect(response_body["pagination"]).to eq(expected_pagination)
        end
      end

      context "when the postcode param is passed" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/#{type}/search", { postcode: "SW1A 2AA" }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000-0001")
        end
      end

      context "when the council param is passed" do
        let(:response) do
          get "/api/#{type}/search", { council: ["South lanarkshire"] }
        end

        let(:multiple_responses) do
          get "/api/#{type}/search", { council: ["South Lanarkshire", "hammersmith and Fulham"] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000-0002")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when the constituency param is passed" do
        let(:response) do
          get "/api/#{type}/search", { constituency: ["lanark and Hamilton East"] }
        end

        let(:multiple_responses) do
          get "/api/#{type}/search", { constituency: ["Lanark and Hamilton East", "Chelsea and Fulham"] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000-0002")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when the efficiency_rating param is passed" do
        let(:response) do
          get "/api/#{type}/search", { efficiency_rating: %w[B] }
        end

        let(:multiple_responses) do
          get "/api/#{type}/search", { efficiency_rating: %w[B e] }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq type == "display" ? 4 : 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000-0000")
        end

        it "returns the correct assessments for multiple inputs" do
          response_body = JSON.parse(multiple_responses.body)
          expect(multiple_responses.status).to eq(200)
          domestic_count = 4
          non_domestic_count = 2
          dec_count = 4
          expect(response_body["data"].length).to eq(
            case type
            when "domestic" then domestic_count
            when "non-domestic" then non_domestic_count
            else dec_count
            end,
          )
        end
      end

      context "when the address param is passed" do
        let(:response) do
          get "/api/#{type}/search", { address: "2 Banana Street" }
        end

        it "returns the correct assessment" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
          expect(response_body["data"].first["certificateNumber"]).to eq("0000-0000-0000-0000-0003")
        end
      end

      context "when the page_size param is passed" do
        let(:response) do
          get "/api/#{type}/search?date_start=2018-01-01&date_end=2025-01-01&page_size=4"
        end

        it "returns the correct number of rows" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 4
        end
      end

      context "when the uprn param is passed" do
        let(:response) do
          get "/api/#{type}/search?uprn=100121241799"
        end

        it "returns the correct number of rows" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"].length).to eq 1
        end
      end
    end

    context "when getting an error response" do
      context "when no params are passed and dates are missing" do
        let(:response) do
          get "/api/#{type}/search"
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the missing params" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please provide a valid date range or search parameter"
        end
      end

      context "when dates are out of range" do
        let(:response) do
          get "/api/#{type}/search?date_start=2025-01-01&date_end=2018-01-01"
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
          tomorrow = Date.tomorrow.strftime "%Y-%m-%d"
          get "/api/#{type}/search?date_start=2014-01-01", { date_end: tomorrow }
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
          get "/api/#{type}/search?date_start=2018-01-01&date_end=2018-02-01"
        end

        it "returns 404" do
          expect(response.status).to eq(404)
        end

        it "raises an error for no results found" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "No certificates could be found for that query"
        end
      end

      context "when postcode is invalid" do
        let(:response) do
          get "/api/#{type}/search", { postcode: "invalid postcode" }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the invalid postcode" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please provide a valid postcode"
        end
      end

      context "when uprn is not an integer" do
        let(:response) do
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2018-01-01", { uprn: "not-an-integer" }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the invalid uprn type" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "the uprn should be an integer"
        end
      end

      context "when council is invalid" do
        let(:response) do
          get "/api/#{type}/search", { council: ["invalid council"] }
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
          get "/api/#{type}/search", { constituency: ["invalid constituency"] }
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
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: -1 }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number -1 is out of range. Please provide a page number between 1 and 1"
        end
      end

      context "when current_page is zero" do
        let(:response) do
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: 0 }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number 0 is out of range. Please provide a page number between 1 and 1"
        end
      end

      context "when current_page is not a number" do
        let(:response) do
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2022-01-01", { current_page: "not-a-number" }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page number 0 is out of range. Please provide a page number between 1 and 1"
        end
      end

      context "when page_size is greater than 5000" do
        let(:response) do
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2022-01-01", { page_size: 5001 }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page size 5001 is out of range. Please provide a page size between 1 and 5000"
        end
      end

      context "when page_size is less than 1" do
        let(:response) do
          get "/api/#{type}/search?date_start=2014-01-01&date_end=2022-01-01", { page_size: 0 }
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the pagination out of range error" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "The requested page size 0 is out of range. Please provide a page size between 1 and 5000"
        end
      end
    end
  end
end

shared_examples "a count API endpoint" do |type:|
  context "when requesting a response from /api/#{type}/count" do
    context "when the response is a success" do
      context "when no optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/#{type}/count?date_start=2018-01-01&date_end=2025-01-01"
        end

        it "returns 5 rows of data" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq({ "count" => 5 })
        end
      end

      context "when optional search filters are added" do
        let(:response) do
          header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
          get "/api/#{type}/count", { efficiency_rating: %w[A B] }
        end

        it "returns correct number of rows of data for efficiency rating filter" do
          response_body = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(response_body["data"]).to eq type == "dec" ? { "count" => 4 } : { "count" => 1 }
        end
      end
    end

    context "when using a wrong token" do
      let(:response) do
        header("Authorization", "Bearer #{get_valid_jwt(%w[warehouse:read])}")
        get("/api/#{type}/count?date_start=2018-01-01&date_end=2025-01-01")
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
