module UseCase
  class SaveReport
    def initialize(reporting_gateway:, reporting_redis_gateway:, report_name:)
      @reporting_gateway = reporting_gateway
      @reporting_redis_gateway = reporting_redis_gateway
      @report_name = report_name
    end

    def execute
      data = @reporting_gateway.send(@report_name)
      @reporting_redis_gateway.save_report(@report_name, data)
    end
  end
end
