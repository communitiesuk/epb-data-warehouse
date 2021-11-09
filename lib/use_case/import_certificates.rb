module UseCase
  class ImportCertificates
    def initialize(eav_gateway:, certificate_gateway:, queues_gateway:)
      @assessment_attribute_gateway = eav_gateway
      @certificate_gateway = certificate_gateway
      @queues_gateway = queues_gateway
    end

    def execute
      assessment_ids = @queues_gateway.consume_queue(:assessments)

      assessment_ids.each do |assessment_id|
        import_xml_certificate_use_case.execute(assessment_id)
      end
    end

  private

    def import_xml_certificate_use_case
      @import_xml_certificate_use_case ||= UseCase::ImportXmlCertificate.new(
        import_certificate_data_use_case: UseCase::ImportCertificateData.new(assessment_attribute_gateway: @assessment_attribute_gateway),
        assessment_attribute_gateway: @assessment_attribute_gateway,
        certificate_gateway: @certificate_gateway,
      )
    end
  end
end
