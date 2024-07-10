desc "Export assessment documents in json format to an S3 bucket"

task :export_documents do
  raise Boundary::ArgumentMissing, "bucket_name" unless ENV["BUCKET_NAME"]

  storage_gateway = Container.storage_gateway(stub_responses: false)
  documents_gateway = Gateway::DocumentsGateway.new
  use_case = UseCase::ExportAssessmentDocuments.new(documents_gateway:, storage_gateway:)

  use_case.execute
end
