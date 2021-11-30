module UseCase
  class ImportXmlCertificate
    def initialize(import_certificate_data_use_case:, assessment_attribute_gateway:, certificate_gateway:)
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

      configuration_class = export_configuration(meta_data[:schemaType])
      return if configuration_class.nil?

      export_config = configuration_class.new
      parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: assessment_id))
      certificate = parser.parse(xml)

      certificate["schema_type"] = meta_data[:schemaType]
      certificate["assessment_address_id"] = meta_data[:assessmentAddressId]
      certificate["created_at"] = meta_data[:createdAt]

      begin
        @import_certificate_data_use_case.execute(assessment_id: assessment_id, certificate_data: certificate)
      rescue Boundary::DuplicateAttribute
        # do nothing
      end
    end

  private

    def export_configuration(schema_type)
      export_config_file = {
        "RdSAP-Schema-20.0.0" => XmlPresenter::Rdsap::Rdsap20ExportConfiguration,
        "SAP-Schema-18.0.0" => XmlPresenter::Sap::Sap1800ExportConfiguration,
        "CEPC-8.0.0" => XmlPresenter::Cepc::Cepc800ExportConfiguration,
      }
      export_config_file[schema_type]
    end
  end
end
