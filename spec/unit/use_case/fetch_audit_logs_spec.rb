describe UseCase::FetchAuditLogs do
  subject(:use_case) do
    described_class.new(audit_logs_gateway:)
  end

  let(:audit_logs_gateway) do
    instance_double(Gateway::AuditLogsGateway)
  end

  let(:start_date) { "2023-01-01" }
  let(:end_date) { "2023-01-31" }

  before do
    allow(audit_logs_gateway).to receive(:fetch_logs)
  end

  describe "#execute" do
    it "calls the correct gateway method" do
      use_case.execute(start_date: start_date, end_date: end_date)
      expect(audit_logs_gateway).to have_received(:fetch_logs).with(start_date: start_date, end_date: end_date).exactly(1).times
    end

    it "raises an error if start_date is after end_date" do
      expect {
        use_case.execute(start_date: "2023-02-01", end_date: "2023-01-31")
      }.to raise_error(Boundary::InvalidDates)
    end
  end
end
