module UseCase
  class ImportXmlCertificate
    def initialize(import_certificate_data_use_case, assessment_attribute_gateway, certificate_gateway)
      @import_certificate_data_use_case = import_certificate_data_use_case
      @assessment_attribute_gateway = assessment_attribute_gateway
      @certificate_gateway = certificate_gateway
    end

    def execute(assessment_id)
      xml = @certificate_gateway.fetch(assessment_id)
      meta_data = @certificate_gateway.fetch_meta_data(assessment_id)

      if @assessment_attribute_gateway.assessment_exists(assessment_id)
        @assessment_attribute_gateway.delete_attributes_by_assessment(assessment_id)
      end

      export_config = export_configuration(meta_data[:schemaType]).new
      parser = XmlPresenter::Parser.new(**export_config.to_args)
      certificate = parser.parse(xml)

      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_address_id"] = meta_data[:assessmentAddressId]
      certificate["created_at"] = meta_data[:createdAt]

      begin
        @import_certificate_data_use_case.execute(assessment_id: assessment_id, certificate_data: certificate)
      rescue Boundary::DuplicateAttribute
        # do nothing
      rescue Boundary::JsonAttributeSave
        # do nothing
      end
    end

  private

    def export_configuration(schema_type)
      if schema_type == "RdSAP-Schema-20.0.0"
        XmlPresenter::Rdsap::Rdsap20ExportConfiguration
      end
    end
  end
end
