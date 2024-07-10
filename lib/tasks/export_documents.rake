desc "Export assessment documents in json format to an S3 bucket"

task :export_documents do
  raise Boundary::ArgumentMissing, "bucket_name" unless ENV["BUCKET_NAME"]
  raise Boundary::ArgumentMissing, "date_from" unless ENV["DATE_FROM"]
  raise Boundary::ArgumentMissing, "date_to" unless ENV["DATE_TO"]
  raise Boundary::InvalidDates unless ENV["DATE_FROM"] <= ENV["DATE_TO"]

  date_from = ENV["DATE_FROM"]
  date_to = ENV["DATE_TO"]

  storage_gateway = Container.storage_gateway(stub_responses: false)
  documents_gateway = Gateway::DocumentsGateway.new
  use_case = UseCase::ExportAssessmentDocuments.new(documents_gateway:, storage_gateway:)

  use_case.execute(date_from:, date_to:)
end
