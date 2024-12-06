module UseCase
  class ExportAssessmentDocuments
    def initialize(documents_gateway:, storage_gateway:)
      @documents_gateway = documents_gateway
      @storage_gateway = storage_gateway
    end

    def execute(date_from:, date_to:)
      assessment_ids = @documents_gateway.fetch_assessments(date_from:, date_to:)

      assessment_ids.each do |row|
        assessment_document = @documents_gateway.fetch_redacted(assessment_id: row[:assessment_id])
        begin
          @storage_gateway.write_file(file_name: "#{row[:assessment_id]}.json", data: assessment_document[:document])
        rescue Aws::S3::Errors::ServiceError
          raise
        end
      end
    end
  end
end
