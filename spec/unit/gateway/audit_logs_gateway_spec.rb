describe Gateway::AuditLogsGateway do
  subject(:gateway) { described_class.new }

  before do
    clear_materialized_views
  end

  describe "#insert_logs" do
    let(:logs) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT assessment_id, event_type, timestamp FROM audit_logs",
      )
    end

    let(:event_type) { "cancelled" }
    let(:assessment_id) { "0000-0000-0001-1234-0000" }

    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE audit_logs")
    end

    it "saves the row to the table" do
      timestamp = "2025-01-01 00:00:00"
      gateway.insert_log(assessment_id:, event_type:, timestamp:)
      expect(logs.rows.length).to eq 1
      expect(logs.rows[0]).to eq [assessment_id, event_type, Time.parse(timestamp)]
    end

    context "when the same assessment_id and the same event are being saved" do
      before do
        gateway.insert_log(assessment_id:, event_type:, timestamp: "2024-01-01 00:00:00")
      end

      it "does not raise an error" do
        expect { gateway.insert_log(assessment_id:, event_type:, timestamp: "2025-02-01 00:00:01") }.not_to raise_error
      end

      it "there is only one row for the assessment" do
        gateway.insert_log(assessment_id:, event_type:, timestamp: "2025-02-01 00:00:01")
        expect(logs.length).to eq 1
      end

      it "the assessment has an updated time stamp" do
        gateway.insert_log(assessment_id:, event_type:, timestamp: "2025-02-01 00:00:01")
        expect(logs.first["timestamp"].to_s).to eq "2025-02-01 00:00:01 UTC"
      end
    end

    context "when the different assessment_ids with the same event are being saved" do
      let(:rrns) do
        %w[0000-0000-0001-1234-0000 0000-0000-0001-1234-0001 0000-0000-0001-1234-0003]
      end

      before do
        rrns.each do |assessment_id|
          gateway.insert_log(assessment_id:, event_type:, timestamp: "2025-02-01 00:00:01")
        end
      end

      it "saves 3 row to the table" do
        expect(logs.rows.length).to eq 3
      end

      it "there are 3 unique assessment_ids in the table" do
        result = logs.map { |row| row["assessment_id"] }
        expect(result).to eq rrns
      end

      context "when adding a assessment that already exists" do
        it "updates only the date of that assessment id" do
          gateway.insert_log(assessment_id: "0000-0000-0001-1234-0000", event_type:, timestamp: "2025-06-01 00:00:01")
          updated_row = logs.map { |row| row }.select { |i| i["timestamp"] == "2025-06-01 00:00:01" }
          expect(updated_row.length).to eq 1
        end
      end
    end

    context "when no timestamp is set" do
      before do
        Timecop.freeze(Time.utc(2014, 7, 4, 12, 0))
      end

      after do
        Timecop.return
      end

      it "does not raise an error" do
        expect { gateway.insert_log(assessment_id:, event_type:, timestamp: nil) }.not_to raise_error
      end

      it "the new row timestamp column has a default value" do
        gateway.insert_log(assessment_id:, event_type:, timestamp: nil)
        expect(logs[0]["timestamp"]).to eq Time.now
      end

      it "the assessment has an updated time stamp" do
        gateway.insert_log(assessment_id:, event_type:, timestamp: "2025-02-01 00:00:01")
        expect(logs.first["timestamp"].to_s).to eq "2025-02-01 00:00:01 UTC"
      end
    end
  end

  describe "#fetch_logs" do
    before do
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE audit_logs")
      gateway.insert_log(assessment_id: "0000-0000-0000-0000", event_type: "cancelled", timestamp: "2025-01-01 00:00:00")
      gateway.insert_log(assessment_id: "0000-0000-0000-0001", event_type: "opt_out", timestamp: "2025-02-01 00:00:00")
      gateway.insert_log(assessment_id: "0000-0000-0000-0002", event_type: "address_id_updated", timestamp: "2025-03-01 00:00:00")
    end

    context "when fetch_logs is executed" do
      before { gateway.insert_log(assessment_id: "0000-0000-0000-0003", event_type: "opt_in", timestamp: "2025-03-01 00:00:00") }

      it "presents removed and address_id_update as new event_type names" do
        result = gateway.fetch_logs(date_start: "2025-01-01", date_end: "2025-03-01")
        expect(result.map { |l| l["event_type"] }).to eq %w[removed removed address_id_update]
      end

      it "does not return logs with event_type 'opt_in'" do
        result = gateway.fetch_logs(date_start: "2025-01-01", date_end: "2025-03-01")
        expect(result.length).to eq 3
        expect(result.map { |l| l["event_type"] }).not_to include "opt_in"
      end
    end

    context "when filtering by date" do
      it "returns all results when the filter date range covers all results" do
        result = gateway.fetch_logs(date_start: "2025-01-01", date_end: "2025-03-01")
        expect(result.length).to eq 3
        expect(result.map { |l| l["certificate_number"] }.sort!).to eq %w[0000-0000-0000-0000 0000-0000-0000-0001 0000-0000-0000-0002]
      end

      it "returns relevant results in filter date range" do
        result = gateway.fetch_logs(date_start: "2025-01-15", date_end: "2025-02-15")
        expect(result.length).to eq 1
        expect(result.first["certificate_number"]).to eq "0000-0000-0000-0001"
      end
    end
  end
end
