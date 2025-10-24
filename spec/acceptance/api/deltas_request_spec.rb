describe "DeltasController" do
  include RSpecDataWarehouseApiServiceMixin
  context "when requesting a response from /api/deltas" do
    let(:audit_logs_gateway) do
      Gateway::AuditLogsGateway.new
    end

    let(:opt_out_expected_data) do
      { "certificateNumber" => "0000-0000-0000-0000",
        "eventType" => "removed",
        "timestamp" => "2025-02-01T00:00:01.000Z" }
    end

    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE audit_logs")

      audit_logs_gateway.insert_log(assessment_id: "0000-0000-0000-0000", event_type: "opt_out", timestamp: "2025-02-01 00:00:01")
      audit_logs_gateway.insert_log(assessment_id: "0000-0000-0000-0001", event_type: "cancelled", timestamp: "2025-02-02 00:00:01")
      audit_logs_gateway.insert_log(assessment_id: "0000-0000-0000-0002", event_type: "address_id_updated", timestamp: "2025-02-03 00:00:01")
      stub_bearer_token_access
    end

    context "when the response is a success" do
      let(:response) do
        get "/api/deltas?date_start=2024-01-01&date_end=2025-03-01"
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "returns the correct amount of audit logs" do
        response_body = JSON.parse(response.body)
        expect(response_body["data"].length).to eq 3
        expect(response_body["data"].map { |i| i["certificateNumber"] }.sort!).to eq %w[0000-0000-0000-0000 0000-0000-0000-0001 0000-0000-0000-0002]
      end

      it "returns the correct data for the opt_out event" do
        response_body = JSON.parse(response.body)
        expect(response_body["data"].find { |i| i["certificateNumber"] == "0000-0000-0000-0000" }).to eq opt_out_expected_data
      end

      context "when there is a single date range" do
        let(:response) do
          get "/api/deltas?date_start=2025-02-01&date_end=2025-02-01"
        end

        it "returns 200" do
          expect(response.status).to eq(200)
        end
      end

      context "when the date range include yesterday" do
        before { Timecop.freeze("2025-02-04 11:00:00 UTC") }

        after { Timecop.return }

        let(:deltas_response) do
          get "/api/deltas?date_start=2025-02-02&date_end=2025-02-03"
        end

        it "returns 200" do
          expect(deltas_response.status).to eq(200)
        end
      end
    end

    context "when getting an error response" do
      context "when dates are missing" do
        let(:response) do
          get "/api/deltas"
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
          get "/api/deltas?date_start=2025-01-01&date_end=2018-01-01"
        end

        it "returns 400" do
          expect(response.status).to eq(400)
        end

        it "raises an error for the missing dates" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "please provide a valid date range"
        end
      end

      context "when date range includes today" do
        let(:response) do
          tomorrow = Date.tomorrow.strftime "%Y-%m-%d"
          get "/api/deltas?date_start=2014-01-01", { date_end: tomorrow }
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
          get "/api/deltas?date_start=2018-01-01&date_end=2018-02-01"
        end

        it "returns 404" do
          expect(response.status).to eq(404)
        end

        it "raises an error for no results found" do
          response_body = JSON.parse(response.body)
          expect(response_body["data"]["error"]).to include "No audit logs could be found for that query"
        end
      end
    end
  end
end
