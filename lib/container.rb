class Container
  def self.api_client_gateway
    @api_client_gateway ||= Gateway::ApiClient.new
  end

  def self.register_api_gateway
    @register_api_gateway ||= Gateway::RegisterApiGateway.new api_client: api_client_gateway
  end

  def self.assessment_attributes_gateway
    @assessment_attributes_gateway ||= Gateway::AssessmentAttributesGateway.new
  end

  def self.assessment_lookups_gateway
    @assessment_lookups_gateway ||= Gateway::AssessmentLookupsGateway.new
  end

  def self.queues_gateway
    @queues_gateway ||= Gateway::QueuesGateway.new
  end

  def self.recovery_list_gateway
    @recovery_list_gateway ||= Gateway::RecoveryListGateway.new
  end

  def self.documents_gateway
    @documents_gateway ||= Gateway::DocumentsGateway.new
  end

  def self.reporting_gateway
    @reporting_gateway ||= Gateway::ReportingGateway.new
  end

  def self.reporting_redis_gateway
    @reporting_redis_gateway ||= Gateway::ReportingRedisGateway.new
  end

  def self.report_triggers_gateway
    @report_triggers_gateway ||= Gateway::ReportTriggersGateway.new
  end

  def self.cancel_certificates_use_case
    @cancel_certificates_use_case ||= UseCase::CancelCertificates.new eav_gateway: assessment_attributes_gateway,
                                                                      queues_gateway:,
                                                                      api_gateway: register_api_gateway,
                                                                      documents_gateway:,
                                                                      recovery_list_gateway:,
                                                                      logger:
  end

  def self.fetch_certificate_use_case
    @fetch_certificate_use_case ||= UseCase::FetchCertificate.new certificate_gateway: register_api_gateway
  end

  def self.import_certificate_data_use_case
    @import_certificate_data_use_case ||= UseCase::ImportCertificateData.new assessment_attribute_gateway: assessment_attributes_gateway,
                                                                             documents_gateway:,
                                                                             logger:
  end

  def self.import_certificates_use_case
    @import_certificates_use_case ||= UseCase::ImportCertificates.new import_xml_certificate_use_case:,
                                                                      queues_gateway:,
                                                                      recovery_list_gateway:,
                                                                      logger:
  end

  def self.import_xml_certificate_use_case
    @import_xml_certificate_use_case ||= UseCase::ImportXmlCertificate.new import_certificate_data_use_case:,
                                                                           assessment_attribute_gateway: assessment_attributes_gateway,
                                                                           certificate_gateway: register_api_gateway,
                                                                           recovery_list_gateway:,
                                                                           logger:
  end

  def self.opt_out_certificates_use_case
    @opt_out_certificates_use_case = UseCase::OptOutCertificates.new eav_gateway: assessment_attributes_gateway,
                                                                     documents_gateway:,
                                                                     queues_gateway:,
                                                                     certificate_gateway: register_api_gateway,
                                                                     recovery_list_gateway:,
                                                                     logger:
  end

  def self.save_heat_pump_sap_count_use_case
    @save_heat_pump_sap_count_use_case ||= UseCase::SaveHeatPumpSapCount.new(reporting_gateway:, reporting_redis_gateway:)
  end

  def self.run_reports_from_triggers_use_case
    @run_reports_from_triggers_use_case ||= UseCase::RunReportsFromTriggers.new report_triggers_gateway:,
                                                                                logger:,
                                                                                report_use_cases: {
                                                                                  heat_pump_count_for_sap: save_heat_pump_sap_count_use_case,
                                                                                }
  end

  def self.pull_queues_use_case
    @pull_queues_use_case ||= UseCase::PullQueues.new
  end

  def self.logger
    @logger ||= Logger.new($stdout, level: Logger::ERROR)
  end

  def self.reset!
    instance_variables.each { |var| instance_variable_set(var, nil) }
  end
end
