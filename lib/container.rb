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

  def self.cancel_certificate_use_case
    @cancel_certificate_use_case ||= UseCase::CancelCertificate.new eav_gateway: assessment_attributes_gateway,
                                                                    queues_gateway: queues_gateway,
                                                                    api_gateway: register_api_gateway
  end

  def self.fetch_certificate_use_case
    @fetch_certificate_use_case ||= UseCase::FetchCertificate.new certificate_gateway: register_api_gateway
  end

  def self.import_certificate_data_use_case
    @import_certificate_data_use_case ||= UseCase::ImportCertificateData.new assessment_attribute_gateway: assessment_attributes_gateway
  end

  def self.import_certificates_use_case
    @import_certificates_use_case ||= UseCase::ImportCertificates.new import_xml_certificate_use_case: import_xml_certificate_use_case,
                                                                      queues_gateway: queues_gateway
  end

  def self.import_xml_certificate_use_case
    @import_xml_certificate_use_case ||= UseCase::ImportXmlCertificate.new import_certificate_data_use_case: import_certificate_data_use_case,
                                                                           assessment_attribute_gateway: assessment_attributes_gateway,
                                                                           certificate_gateway: register_api_gateway
  end

  def self.opt_out_certificate_use_case
    @opt_out_certificate_use_case = UseCase::OptOutCertificate.new eav_gateway: assessment_attributes_gateway,
                                                                   queues_gateway: queues_gateway,
                                                                   certificate_gateway: register_api_gateway
  end

  def self.reset!
    instance_variables.each { |var| instance_variable_set(var, nil) }
  end
end
