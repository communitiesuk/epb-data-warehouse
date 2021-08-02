module UseCase
  class ImportXmlCertificate < UseCase::ImportBase
    attr_accessor :assessment_attribute_gateway
    def initialize(assessment_gateway)
      @assessment_attribute_gateway = assessment_gateway
    end

    def execute(xml, schema_type)
      wrapper =
        ViewModel::Factory.new.create(
          xml,
          schema_type,
        )
      certificate = wrapper.to_report
      assessment_id = certificate["assessment_id"]
      begin
        save_attributes(assessment_id, certificate)
      rescue Boundary::DuplicateAttribute
      rescue Boundary::JsonAttributeSave
      end
    end
  end
end
