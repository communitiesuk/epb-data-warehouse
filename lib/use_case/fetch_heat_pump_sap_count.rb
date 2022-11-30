module UseCase
  class FetchHeatPumpSapCount
    def initialize(reporting_gateway)
      @reporting_gateway = reporting_gateway
    end

    def execute
      @reporting_gateway.heat_pump_count_for_sap
    end
  end
end
