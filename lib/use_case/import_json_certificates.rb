require "json"

module UseCase
  class ImportJsonCertificates
    # @deprecated
    # This is used only to seed dev data and is not a core part of the data warehouse.
    # It should be removed when the seed_test_data task is updated to use XML.
    attr_accessor :file_gateway, :import_certificate_data_use_case

    def initialize(file_gateway:, import_certificate_data_use_case:)
      @file_gateway = file_gateway
      @import_certificate_data_use_case = import_certificate_data_use_case
    end

    def execute
      files = @file_gateway.read
      files.each do |f|
        certificate = JSON.parse(File.read(f).force_encoding("utf-8"))
        assessment_id = certificate["assessment_id"]
        import_certificate_data_use_case.execute(assessment_id:, certificate_data: certificate)
      end
    end
  end
end
