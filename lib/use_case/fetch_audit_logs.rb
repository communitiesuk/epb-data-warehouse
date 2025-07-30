module UseCase
  class FetchAuditLogs
    def initialize(audit_logs_gateway:)
      @audit_logs_gateway = audit_logs_gateway
    end

    def execute(start_date:, end_date:)
      raise Boundary::InvalidDates if start_date > end_date

      @audit_logs_gateway.fetch_logs(start_date:, end_date:)
    end
  end
end
