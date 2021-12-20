module UseCase
  class ImportCertificates
    def initialize(import_xml_certificate_use_case:, queues_gateway:, recovery_list_gateway:, logger: nil)
      @import_xml_certificate_use_case = import_xml_certificate_use_case
      @queues_gateway = queues_gateway
      @recovery_list_gateway = recovery_list_gateway
      @logger = logger
    end

    def execute(from_recovery_list: false)
      if from_recovery_list
        assessment_ids = Helper::Stopwatch.log_elapsed_time @logger, "Batch fetched from recovery list" do
          @recovery_list_gateway.assessments queue: :assessments
        end
      else
        assessment_ids = Helper::Stopwatch.log_elapsed_time @logger, "Batch fetched from queue" do
          @queues_gateway.consume_queue(:assessments)
        end
        register_to_recovery_list assessment_ids
      end

      Helper::Stopwatch.log_elapsed_time @logger, "Batch of size #{assessment_ids.length} imported" do
        assessment_ids.each do |assessment_id|
          Helper::Stopwatch.log_elapsed_time @logger, "Assessment #{assessment_id} imported" do
            @import_xml_certificate_use_case.execute(assessment_id)
          end
        end
      end
    rescue StandardError => e
      report_to_sentry(e)
      @logger.error "Error of type #{e.class} when importing certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end

  private

    def register_to_recovery_list(assessment_ids)
      @recovery_list_gateway.register_assessments(*assessment_ids, queue: :assessments)
    end
  end
end
