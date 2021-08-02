desc "Import assessments fixture into to the dev database for testing"


task :seed_test_data do


  json_dir_path = File.join(Dir.pwd, "spec/fixtures/json_export/")
  certificates_gateway = Gateway::JsonCertificates.new(json_dir_path)
  use_case = UseCase::ImportJsonCertificates.new(certificates_gateway, Gateway::AssessmentAttributesGateway.new)

  use_case.execute
  pp 'seed data added to database'
end