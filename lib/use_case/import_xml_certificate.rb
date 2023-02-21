module UseCase
  class ImportXmlCertificate
    include Helper::MetaDataRule

    class UnimportableAssessment < RuntimeError; end

    def initialize(import_certificate_data_use_case:, assessment_attribute_gateway:, certificate_gateway:, recovery_list_gateway:, logger: nil)
      @import_certificate_data_use_case = import_certificate_data_use_case
      @assessment_attribute_gateway = assessment_attribute_gateway
      @certificate_gateway = certificate_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
    end

    def execute(assessment_id)
      xml = nil
      meta_data = nil

      fetch_error = nil

      Helper::Stopwatch.log_elapsed_time @logger, "combined API fetches for #{assessment_id}" do
        Async annotation: "API fetches" do |task|
          task.async annotation: "fetch XML" do
            xml = Helper::Stopwatch.log_elapsed_time @logger, "XML for #{assessment_id} fetched" do
              @certificate_gateway.fetch(assessment_id)
            end
          rescue StandardError => e
            fetch_error = e
            task.stop
          end

          task.async annotation: "fetch metadata" do
            meta_data = Helper::Stopwatch.log_elapsed_time @logger, "metadata for #{assessment_id} fetched" do
              @certificate_gateway.fetch_meta_data(assessment_id)
            end
          rescue StandardError => e
            fetch_error = e
            task.stop
          end
        end
      end

      raise UnimportableAssessment if fetch_error.is_a?(Errors::AssessmentGone)

      raise fetch_error if fetch_error

      raise StandardError if xml.nil? || meta_data.nil?

      raise UnimportableAssessment if should_exclude?(meta_data:)

      if @assessment_attribute_gateway.assessment_exists(assessment_id)
        Helper::Stopwatch.log_elapsed_time @logger, "deleted EAV attributes for assessment #{assessment_id}" do
          @assessment_attribute_gateway.delete_attributes_by_assessment(assessment_id)
        end
      end

      parse = UseCase::ParseXmlCertificate.new

      certificate = parse.execute(xml:,
                                  schema_type: meta_data[:schemaType],
                                  assessment_id:)
      raise UnimportableAssessment if certificate.nil?

      certificate["assessment_address_id"] = meta_data[:assessmentAddressId]
      certificate["created_at"] = Helper::DateTime.convert_atom_to_db_datetime(meta_data[:createdAt]) if meta_data[:createdAt]
      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_type"] = meta_data[:typeOfAssessment]

      certificate["cancelled_at"] = Helper::DateTime.convert_atom_to_db_datetime(meta_data[:cancelledAt]) unless meta_data[:cancelledAt].nil?
      certificate["opt_out"] = Time.now.utc.strftime("%F %T") if meta_data[:optOut]

      Helper::Stopwatch.log_elapsed_time @logger, "imported parsed assessment data for assessment #{assessment_id}" do
        @import_certificate_data_use_case.execute(assessment_id:, certificate_data: certificate)
      end

      clear_from_recovery_list assessment_id
    rescue UnimportableAssessment
      clear_from_recovery_list assessment_id
    rescue StandardError => e
      report_to_sentry(e) if is_on_last_attempt(assessment_id)
      @logger.error "Error of type #{e.class} when importing RRN #{assessment_id}: '#{e.message}'" if @logger.respond_to?(:error)
      register_attempt_to_recovery_list assessment_id
    end

  private

    def clear_from_recovery_list(assessment_id)
      @recovery_list_gateway.clear_assessment assessment_id, queue: :assessments
    end

    def register_attempt_to_recovery_list(assessment_id)
      @recovery_list_gateway.register_attempt(assessment_id:, queue: :assessments)
    end

    def is_on_last_attempt(assessment_id)
      @recovery_list_gateway.retries_left(assessment_id:, queue: :assessments) >= 1
    end
  end
end
