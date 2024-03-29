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

  def self.export_heat_pump_by_property_type_use_case
    @export_heat_pump_by_property_type_use_case ||= UseCase::ExportHeatPumpByPropertyType.new(export_gateway: export_heat_pumps_gateway, file_gateway: file_gateway("heat_pump_count_by_property_type.csv"), notify_gateway:)
  end

  def self.export_heat_pumps_gateway
    @export_heat_pumps_gateway ||= Gateway::ExportHeatPumpsGateway.new
  end

  def self.file_gateway(file_name)
    @file_gateway || Gateway::FileGateway.new(file_name)
  end

  def self.notify_gateway
    @notify_gateway || Gateway::FileGateway.new(ENV["NOTIFY_API_KEY"])
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
