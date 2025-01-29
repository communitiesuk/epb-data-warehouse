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

  def self.ons_gateway
    @ons_gateway ||= Gateway::OnsPostcodeDirectoryNamesGateway.new
  end

  def self.cancel_certificates_use_case
    @cancel_certificates_use_case ||= UseCase::CancelCertificates.new eav_gateway: assessment_attributes_gateway,
                                                                      queues_gateway:,
                                                                      api_gateway: register_api_gateway,
                                                                      documents_gateway:,
                                                                      recovery_list_gateway:,
                                                                      logger:,
                                                                      assessments_country_id_gateway:
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
                                                                           logger:,
                                                                           assessments_country_id_gateway:
  end

  def self.opt_out_certificates_use_case
    @opt_out_certificates_use_case = UseCase::OptOutCertificates.new eav_gateway: assessment_attributes_gateway,
                                                                     documents_gateway:,
                                                                     queues_gateway:,
                                                                     certificate_gateway: register_api_gateway,
                                                                     recovery_list_gateway:,
                                                                     logger:
  end

  def self.send_heat_pump_counts_use_case
    @send_heat_pump_counts_use_case ||= UseCase::SendHeatPumpCounts.new(export_gateway: export_heat_pumps_gateway, file_gateway:, notify_gateway:)
  end

  def self.get_heat_pump_counts_by_floor_area_use_case
    @get_heat_pump_counts_by_floor_area_use_case ||= UseCase::GetHeatPumpCountsByFloorArea.new(export_gateway: export_heat_pumps_gateway)
  end

  def self.export_heat_pumps_gateway
    @export_heat_pumps_gateway ||= Gateway::ExportHeatPumpsGateway.new
  end

  def self.assessments_country_id_gateway
    @assessments_country_id_gateway ||= Gateway::AssessmentsCountryIdGateway.new
  end

  def self.file_gateway
    @file_gateway ||= Gateway::FileGateway.new
  end

  def self.notify_gateway
    @notify_gateway ||= Gateway::NotifyGateway.new(Notifications::Client.new(ENV["NOTIFY_CLIENT_API_KEY"]))
  end

  def self.update_certificate_addresses_use_case
    @update_certificate_addresses_use_case ||= UseCase::UpdateCertificateAddresses.new eav_gateway: assessment_attributes_gateway,
                                                                                       documents_gateway:,
                                                                                       queues_gateway:,
                                                                                       recovery_list_gateway:,
                                                                                       logger:
  end

  def self.pull_queues_use_case
    @pull_queues_use_case ||= UseCase::PullQueues.new
  end

  def self.average_co2_emissions_gateway
    @average_co2_emissions_gateway ||= Gateway::AverageCo2EmissionsGateway.new
  end

  def self.materialized_views_gateway
    @materialized_views_gateway ||= Gateway::MaterializedViewsGateway.new
  end

  def self.fetch_average_co2_emissions_use_case
    @fetch_average_co2_emissions_use_case ||= UseCase::FetchAverageCo2Emissions.new(gateway: average_co2_emissions_gateway)
  end

  def self.refresh_average_co2_emissions
    @refresh_average_co2_emissions ||= UseCase::RefreshAverageCo2Emissions.new(gateway: average_co2_emissions_gateway)
  end

  def self.refresh_materialized_views_use_case
    @refresh_materialized_views_use_case ||= UseCase::RefreshMaterializedView.new(gateway: materialized_views_gateway)
  end

  def self.logger
    @logger ||= Logger.new($stdout, level: Logger::ERROR)
  end

  def self.reset!
    instance_variables.each { |var| instance_variable_set(var, nil) }
  end

  def self.domestic_search_gateway
    @domestic_search_gateway ||= Gateway::DomesticSearchGateway.new
  end

  def self.domestic_search_use_case
    @domestic_search_use_case ||= UseCase::DomesticSearch.new(search_gateway: domestic_search_gateway, ons_gateway: ons_gateway)
  end

  def self.storage_gateway(stub_responses: true)
    @storage_gateway ||= Gateway::StorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses:)
  end
end
