require "json"

module UseCase
  class ImportJsonCertificates < UseCase::ImportBase
    # @deprecated
    # This is used only to seed dev data and is not a core part of the data warehouse.
    # It should be removed when the seed_test_data task is updated to use XML.
    attr_accessor :file_gateway, :assessment_attribute_gateway

    def initialize(file_gateway, assessment_gateway)
      super()
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
          # do nothing
        rescue Boundary::JsonAttributeSave
          # do nothing
        end
      end
    end
  end
end
