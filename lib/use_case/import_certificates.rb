module UseCase
  class ImportCertificates < UseCase::ImportBase
    def initialize(eav_gateway, certificate_gateway, redis_gateway)
      @assessment_attribute_gateway = eav_gateway
      @certificate_gateway = certificate_gateway
      @redis_gateway = redis_gateway
    end

    def execute
      assessment_ids = @redis_gateway.fetch_queue("queues", "assessments")
      # TODO: Decide where we are getting the schema from , either a new end point or add it to the queue?
      schema_type = "TODO"

      assessment_ids.each do |assessment_id|
        import_xml_certificate_use_case.execute(assessment_id, schema_type)
        @redis_gateway.remove_from_queue(
          assessment_id: assessment_id,
          queue: "queues",
          child_queue: "assessments"
        )
      end
    end

    private

    def import_xml_certificate_use_case
      @import_xml_certificate_use_case ||= UseCase::ImportXmlCertificate.new(
        @assessment_attribute_gateway,
        @certificate_gateway
      )
    end
  end
end
