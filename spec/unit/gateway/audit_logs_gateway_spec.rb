describe Gateway::AuditLogsGateway do
  subject(:gateway) { described_class.new }

  let(:logs) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM audit_logs",
    )
  end

  before do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE audit_logs CASCADE;")
  end

  describe "#insert" do
    it "saves the row to the table" do
      assessment_id = "0000-0000-0001-1234-0000"
      event_type = "cancelled"
      timestamp = "2025-01-01 00:00:00"

      gateway.insert_log(assessment_id:, event_type:, timestamp:)
      expect(logs.rows.length).to eq 1
      expect(logs.rows[0]).to eq [assessment_id, event_type, Time.parse(timestamp)]
    end
  end
end
