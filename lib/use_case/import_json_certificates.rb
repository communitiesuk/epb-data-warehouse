module UseCase
  class ImportJsonCertificates < UseCase::ImportBase
    attr_accessor :file_gateway, :assessment_attribute_gateway

    def initialize(file_gateway, assessment_gateway)
      @file_gateway = file_gateway
      @assessment_attribute_gateway = assessment_gateway
    end

    def execute
      files = @file_gateway.read
      files.each do |f|
        certificate = JSON.parse(File.read(f))
        assessment_id = certificate["assessment_id"]
        begin
          save_attributes(assessment_id, certificate)
        rescue Boundary::DuplicateAttribute
        rescue Boundary::JsonAttributeSave
        end
      end
    end
    end

end
