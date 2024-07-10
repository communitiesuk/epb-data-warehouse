module UseCase
  class ExportAssessmentDocuments
    def initialize(documents_gateway:, storage_gateway:)
      @documents_gateway = documents_gateway
      @storage_gateway = storage_gateway
    end

    def execute
      assessment_documents = @documents_gateway.fetch_assessments_json
      assessment_documents.each do |assessment_document|
        @storage_gateway.write_file(file_name: assessment_document[:assessment_id], data: assessment_document[:document])
      rescue Aws::S3::Errors::ServiceError
        raise
      end
    end
  end
end
