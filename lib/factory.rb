class Factory
  def self.reporting_gateway
    @reporting_gateway ||= Gateway::ReportingGateway.new
  end

  def self.reporting_redis_gateway
    @reporting_redis_gateway ||= Gateway::ReportingRedisGateway.new
  end

  def self.save_heat_pump_sap_count
    @save_heat_pump_sap_count ||= UseCase::SaveHeatPumpSapCount.new(reporting_gateway:, reporting_redis_gateway:)
  end
end
