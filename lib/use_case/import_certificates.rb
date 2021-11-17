module UseCase
  class ImportCertificates
    def initialize(import_xml_certificate_use_case:, queues_gateway:)
      @import_xml_certificate_use_case = import_xml_certificate_use_case
      @queues_gateway = queues_gateway
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:assessments)

      assessment_ids.each do |assessment_id|
        @import_xml_certificate_use_case.execute(assessment_id)
      end
    end
  end
end
