module UseCase
  class ImportCertificates
    def initialize(import_xml_certificate_use_case:, queues_gateway:, logger: nil)
      @import_xml_certificate_use_case = import_xml_certificate_use_case
      @queues_gateway = queues_gateway
      @logger = logger
    end

    def execute
      assessment_ids = Helper::Stopwatch.log_elapsed_time @logger, "Batch fetched from queue" do
        @queues_gateway.consume_queue(:assessments)
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
  end
end
