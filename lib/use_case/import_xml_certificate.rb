module UseCase
  class ImportXmlCertificate
    include Helper::MetaDataRule

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

      return if should_exclude meta_data: meta_data

      if @assessment_attribute_gateway.assessment_exists(assessment_id)
        Helper::Stopwatch.log_elapsed_time @logger, "deleted EAV attributes for assessment #{assessment_id}" do
          @assessment_attribute_gateway.delete_attributes_by_assessment(assessment_id)
        end
      end

      parse = UseCase::ParseXmlCertificate.new

      certificate = parse.execute xml: xml,
                                  schema_type: meta_data[:schemaType],
                                  assessment_id: assessment_id
      return if certificate.nil?

      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_address_id"] = meta_data[:assessmentAddressId]
      certificate["created_at"] = Helper::DateTime.convert_atom_to_db_datetime(meta_data[:createdAt])
      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_type"] = meta_data[:typeOfAssessment]

      certificate["cancelled_at"] = Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt]) unless meta_data[:cancelledAt].nil?
      certificate["opt_out"] = Time.now.utc.strftime("%F %T") if meta_data[:optOut]

      Helper::Stopwatch.log_elapsed_time @logger, "imported parsed assessment data for assessment #{assessment_id}" do
        @import_certificate_data_use_case.execute(assessment_id: assessment_id, certificate_data: certificate)
      end
    rescue StandardError => e
      report_to_sentry e
      @logger.error "Error of type #{e.class} when importing RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
    end
  end
end
