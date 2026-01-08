require "rexml"

desc "Import enums from the xsd schema "
task :import_enums_xsd, %i[config_path] do |_, args|
  config_path = args.config_path || "config/attribute_enum_map.json"
  config_gateway = Gateway::XsdConfigGateway.new(config_path)

  use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
  use_case.execute

  if !ENV["STAGE"].nil? && !ENV["UD_BUCKET_NAME"].nil?
    s3_gateway = Container.s3_gateway
    look_up_gateway = Container.assessment_lookups_gateway
    use_case = UseCase::WriteLookUpCodesS3.new(s3_gateway:, look_up_gateway:)
    use_case.execute(bucket: ENV["UD_BUCKET_NAME"], file_name: "codes.csv")
  end
end
