module UseCase
  class ImportXmlCertificate < UseCase::ImportBase
    def initialize(eav_gateway, certificate_gateway)
      @assessment_attribute_gateway = eav_gateway
      @certificate_gateway = certificate_gateway
    end

    def execute(assessment_id)
      xml = @certificate_gateway.fetch(assessment_id)
      meta_data = @certificate_gateway.fetch_meta_data(assessment_id)
      additional_data = { created_at: meta_data[:createdAt], address_id: meta_data[:addressId] }

      if @assessment_attribute_gateway.assessment_exists(assessment_id)
        @assessment_attribute_gateway.delete_attributes_by_assessment(assessment_id)
      end

      wrapper =
        ViewModel::Factory.new.create(
          xml,
          meta_data[:schemaType],
        )
      assessment_id = wrapper.view_model.assessment_id
      certificate = wrapper.to_report

      certificate[:schema_type] = meta_data[:schemaType]

      begin
        save_attributes(assessment_id, certificate)
      rescue Boundary::DuplicateAttribute
        # do nothing
      rescue Boundary::JsonAttributeSave
        # do nothing
      end
    end
  end
end
