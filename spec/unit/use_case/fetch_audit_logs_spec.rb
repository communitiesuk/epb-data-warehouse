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
    allow(audit_logs_gateway).to receive(:fetch_logs).and_return([{ assessment_id: 1, event_type: "test_type", timestamp: "2023-01-01T12:00:00Z" }])
  end

  describe "#execute" do
    it "calls the correct gateway method" do
      use_case.execute(date_start: start_date, date_end: end_date)
      expect(audit_logs_gateway).to have_received(:fetch_logs).with(date_start: start_date, date_end: end_date).exactly(1).times
    end

    context "when the start date is after the end date" do
      it "raises an InvalidDates error" do
        expect {
          use_case.execute(date_start: "2023-02-01", date_end: "2023-01-31")
        }.to raise_error(Boundary::InvalidDates, "start date cannot be greater than end date")
      end
    end

    context "when the date range includes today" do
      before { Timecop.freeze(2024, 3, 1) }
      after { Timecop.return }

      it "raises an error if end date is set to today" do
        expect {
          use_case.execute(date_start: "2024-02-28", date_end: "2024-03-01")
        }.to raise_error(Boundary::InvalidArgument, "date range cannot include today")
      end

      it "raises an error if start date is set to today" do
        expect {
          use_case.execute(date_start: "2024-03-01", date_end: "2024-03-02")
        }.to raise_error(Boundary::InvalidArgument, "date range cannot include today")
      end
    end

    context "when the dates are missing" do
      it "raises an InvalidDates error" do
        expect {
          use_case.execute(date_start: nil, date_end: nil)
        }.to raise_error(Boundary::Json::ValidationError)
      end
    end

    context "when no logs are found" do
      before do
        allow(audit_logs_gateway).to receive(:fetch_logs).and_return([])
      end

      it "raises a NoData error" do
        expect {
          use_case.execute(date_start: start_date, date_end: end_date)
        }.to raise_error(Boundary::NoData, "There is no data return for 'audit logs'")
      end
    end
  end
end
