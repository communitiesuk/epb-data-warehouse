module UseCase
  class ImportCertificates
    def initialize(eav_gateway:, certificate_gateway:, queues_gateway:)
      @assessment_attribute_gateway = eav_gateway
      @certificate_gateway = certificate_gateway
      @queues_gateway = queues_gateway
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:assessments)

      import_xml_certificate = use_case :import_xml_certificate

      assessment_ids.each do |assessment_id|
        import_xml_certificate.execute(assessment_id)
      end
    end
  end
end
