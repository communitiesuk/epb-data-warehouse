module UseCase
  class SaveHeatPumpSapCount
    def initialize(reporting_gateway:, reporting_redis_gateway:)
      @reporting_gateway = reporting_gateway
      @reporting_redis_gateway = reporting_redis_gateway
    end

    def execute
      data = @reporting_gateway.heat_pump_count_for_sap
      raise Boundary::NoData, "heat_pump_count for SAP" if data.empty?

      @reporting_redis_gateway.save_report(:heat_pump_count_for_sap, data)
    end
  end
end
