desc "Import assessments fixture into to the dev database for testing"
task :seed_test_data do
  # TODO: update this to use the XML import gateway and remove the json_export folder, gateway and use case
  json_dir_path = File.join(Dir.pwd, "spec/fixtures/json_export/")

  certificates_gateway = Gateway::JsonCertificates.new(json_dir_path)

  use_case = UseCase::ImportJsonCertificates.new file_gateway: certificates_gateway,
                                                 import_certificate_data_use_case: use_case(:import_certificate_data)

  use_case.execute
  pp "seed data added to database"
end
