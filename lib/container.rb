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

  def self.audit_logs_gateway
    @audit_logs_gateway ||= Gateway::AuditLogsGateway.new
  end

  def self.assessment_search_gateway
    @assessment_search_gateway ||= Gateway::AssessmentSearchGateway.new
  end

  def self.commercial_reports_gateway
    @commercial_reports_gateway ||= Gateway::CommercialReportsGateway.new
  end

  def self.assessment_search_use_case
    @assessment_search_use_case ||= UseCase::AssessmentSearch.new(assessment_search_gateway:)
  end

  def self.get_pagination_use_case
    @get_pagination_use_case ||= UseCase::GetPagination.new(assessment_search_gateway:)
  end

  def self.cancel_certificates_use_case
    @cancel_certificates_use_case ||= UseCase::CancelCertificates.new eav_gateway: assessment_attributes_gateway,
                                                                      queues_gateway:,
                                                                      api_gateway: register_api_gateway,
                                                                      documents_gateway:,
                                                                      recovery_list_gateway:,
                                                                      audit_logs_gateway:,
                                                                      logger:,
                                                                      assessments_country_id_gateway:,
                                                                      assessment_search_gateway:
  end

  def self.fetch_audit_logs_use_case
    @fetch_audit_logs_use_case ||= UseCase::FetchAuditLogs.new audit_logs_gateway: audit_logs_gateway
  end

  def self.fetch_certificate_use_case
    @fetch_certificate_use_case ||= UseCase::FetchCertificate.new certificate_gateway: register_api_gateway
  end

  def self.import_certificate_data_use_case
    @import_certificate_data_use_case ||= UseCase::ImportCertificateData.new assessment_attribute_gateway: assessment_attributes_gateway,
                                                                             documents_gateway:,
                                                                             assessment_search_gateway:,
                                                                             commercial_reports_gateway:,
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
                                                                     audit_logs_gateway:,
                                                                     assessment_search_gateway:,
                                                                     logger:
  end

  def self.send_heat_pump_counts_use_case
    @send_heat_pump_counts_use_case ||= UseCase::SendHeatPumpCounts.new(export_gateway: export_heat_pumps_gateway, file_gateway:, notify_gateway:)
  end

  def self.get_heat_pump_counts_by_floor_area_use_case
    @get_heat_pump_counts_by_floor_area_use_case ||= UseCase::GetHeatPumpCountsByFloorArea.new(export_gateway: export_heat_pumps_gateway)
  end

  def self.fetch_look_ups_use_case
    @fetch_look_ups_use_case ||= UseCase::FetchLookups.new(gateway: assessment_lookups_gateway)
  end

  def self.fetch_look_up_values_use_case
    @fetch_look_up_values_use_case ||= UseCase::FetchLookupValues.new(gateway: assessment_lookups_gateway)
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
                                                                                       assessment_search_gateway:,
                                                                                       audit_logs_gateway:,
                                                                                       logger:
  end

  def self.update_certificate_matched_addresses_use_case
    @update_certificate_matched_addresses_use_case ||= UseCase::UpdateCertificateMatchedAddresses.new documents_gateway:,
                                                                                                      queues_gateway:,
                                                                                                      recovery_list_gateway:,
                                                                                                      assessment_search_gateway:,
                                                                                                      queue_name: :matched_address_update,
                                                                                                      logger:
  end

  def self.backfill_update_certificate_matched_addresses_use_case
    @backfill_update_certificate_matched_addresses_use_case ||= UseCase::UpdateCertificateMatchedAddresses.new documents_gateway:,
                                                                                                               queues_gateway:,
                                                                                                               recovery_list_gateway:,
                                                                                                               assessment_search_gateway:,
                                                                                                               queue_name: :backfill_matched_address_update,
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

  def self.count_certificates_use_case
    @count_certificates_use_case ||= UseCase::CountCertificates.new(assessment_search_gateway: assessment_search_gateway)
  end

  def self.fix_attribute_duplicates_use_case
    @fix_attribute_duplicates_use_case ||= UseCase::FixAttributeDuplicates.new(assessment_attribute_gateway: assessment_attributes_gateway)
  end

  def self.storage_gateway(stub_responses: true)
    @storage_gateway ||= Gateway::StorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses:)
  end

  def self.multipart_storage_gateway(stub_responses: true)
    @multipart_storage_gateway ||= Gateway::MultipartStorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses:)
  end

  def self.get_redacted_certificate_use_case
    @get_redacted_certificate_use_case ||= UseCase::GetRedactedCertificate.new(documents_gateway:)
  end

  def self.s3_gateway
    @s3_gateway ||= Gateway::S3Gateway.new
  end

  def self.get_presigned_url_use_case
    @get_presigned_url_use_case ||= UseCase::GetPresignedUrl.new(gateway: s3_gateway, bucket_name: ENV["AWS_S3_USER_DATA_BUCKET_NAME"])
  end

  def self.get_file_info_use_case
    @get_file_info_use_case ||= UseCase::GetFileInfo.new(gateway: s3_gateway, bucket_name: ENV["AWS_S3_USER_DATA_BUCKET_NAME"])
  end

  def self.user_credentials_gateway
    @user_credentials_gateway ||= Gateway::UserCredentialsGateway.new
  end

  def self.authenticate_user_use_case
    @authenticate_user_use_case ||= UseCase::AuthenticateUser.new(user_credentials_gateway:)
  end
end
