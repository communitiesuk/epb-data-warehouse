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

      wrapper =
        ViewModel::Factory.new.create(
          xml,
          meta_data[:schemaType],
        )
      assessment_id = wrapper.view_model.assessment_id
      certificate = wrapper.to_report

      certificate[:schema_type] = meta_data[:schemaType]
      certificate[:assessment_address_id] = meta_data[:assessmentAddressId]
      certificate[:created_at] = meta_data[:createdAt]

      begin
        @import_certificate_data_use_case.execute(assessment_id: assessment_id, certificate_data: certificate)
      rescue Boundary::DuplicateAttribute
        # do nothing
      rescue Boundary::JsonAttributeSave
        # do nothing
      end
    end
  end
end
