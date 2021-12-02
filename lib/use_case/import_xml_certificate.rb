require "parallel"

module UseCase
  class ImportXmlCertificate
    def initialize(import_certificate_data_use_case:, assessment_attribute_gateway:, certificate_gateway:, logger: nil)
      @import_certificate_data_use_case = import_certificate_data_use_case
      @assessment_attribute_gateway = assessment_attribute_gateway
      @certificate_gateway = certificate_gateway
      @logger = logger
    end

    def execute(assessment_id)
      xml = Helper::Stopwatch.log_elapsed_time @logger, "XML for #{assessment_id} fetched" do
        @certificate_gateway.fetch(assessment_id)
      end

      meta_data = Helper::Stopwatch.log_elapsed_time @logger, "metadata for #{assessment_id} fetched" do
        @certificate_gateway.fetch_meta_data(assessment_id)
      end

      if @assessment_attribute_gateway.assessment_exists(assessment_id)
        Helper::Stopwatch.log_elapsed_time @logger, "deleted EAV attributes for assessment #{assessment_id}" do
          @assessment_attribute_gateway.delete_attributes_by_assessment(assessment_id)
        end

      end

      configuration_class = export_configuration(meta_data[:schemaType])
      return if configuration_class.nil?

      certificate = Parallel.map([0]) { |_|
        export_config = configuration_class.new
        parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: assessment_id))
        Helper::Stopwatch.log_elapsed_time @logger, "parsed XML for assessment #{assessment_id}" do
          parser.parse(xml)
        end
      }.first

      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_address_id"] = meta_data[:assessmentAddressId]
      certificate["created_at"] = meta_data[:createdAt]

      Helper::Stopwatch.log_elapsed_time @logger, "imported parsed assessment data for assessment #{assessment_id}" do
        @import_certificate_data_use_case.execute(assessment_id: assessment_id, certificate_data: certificate)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    def export_configuration(schema_type)
      export_config_file = {
        "RdSAP-Schema-20.0.0" => XmlPresenter::Rdsap::Rdsap20ExportConfiguration,
        "SAP-Schema-18.0.0" => XmlPresenter::Sap::Sap1800ExportConfiguration,
        "CEPC-8.0.0" => XmlPresenter::Cepc::Cepc800ExportConfiguration,
      }
      export_config_file[schema_type]
    end
  end
end
