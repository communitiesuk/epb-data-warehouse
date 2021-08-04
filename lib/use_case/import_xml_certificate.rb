module UseCase
  class ImportXmlCertificate < UseCase::ImportBase
    def initialize(eav_gateway, certificate_gateway)
      @assessment_attribute_gateway = eav_gateway
      @certificate_gateway = certificate_gateway
    end

    def execute(assessment_id, schema_type)
      xml = @certificate_gateway.fetch(assessment_id)

      wrapper =
        ViewModel::Factory.new.create(
          xml,
          schema_type,
        )
      assessment_id = wrapper.view_model.assessment_id
      certificate = wrapper.to_report
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
