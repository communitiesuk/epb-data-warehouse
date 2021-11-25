module UseCase
  class ImportCertificates
    def initialize(import_xml_certificate_use_case:, queues_gateway:, logger: nil)
      @import_xml_certificate_use_case = import_xml_certificate_use_case
      @queues_gateway = queues_gateway
      @logger = logger
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:assessments)

      assessment_ids.each do |assessment_id|
        @import_xml_certificate_use_case.execute(assessment_id)
      end
    rescue StandardError => e
      report_to_sentry(e)
      @logger.error "Error of type #{e.class} when importing certificates: '#{e.message}'" if @logger.respond_to?(:error)
    end
  end
end
