require "rexml"

desc "Import enums from the xsd schema "
task :import_enums_xsd do
  config_gateway = Gateway::XsdConfigGateway.new("config/attribute_enum_map.json")
  use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
  use_case.execute
  pp "enum values added to database"
end
