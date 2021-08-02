module UseCase
  class ImportXmlCertificate
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
      wrapper.to_report
    end
  end
end
