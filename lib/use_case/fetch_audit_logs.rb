module UseCase
  class FetchAuditLogs
    def initialize(audit_logs_gateway:)
      @audit_logs_gateway = audit_logs_gateway
    end

    def execute(date_start:, date_end:)
      raise Boundary::Json::ValidationError if date_start.nil? || date_end.nil?
      raise Boundary::InvalidDates if date_start > date_end

      range = (Date.parse(date_start)..Date.parse(date_end))
      raise Boundary::InvalidArgument, "date range cannot include today" if range.include? Date.today

      result = @audit_logs_gateway.fetch_logs(date_start:, date_end:)

      raise Boundary::NoData, "audit logs" if result.nil? || result.empty?

      result
    end
  end
end
