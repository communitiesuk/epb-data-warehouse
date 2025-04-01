desc "Save enum data to the database and generate csv to be used in test"
task :generate_enum_csv do
  config_path = "config/attribute_enum_map.json"
  config_gateway = Gateway::XsdConfigGateway.new(config_path)
  use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
  use_case.execute
  data = GenerateEnumHelper.lookup_data
  file_path = "#{Dir.pwd}/spec/fixtures/look_up_data.csv"
  Gateway::FileGateway.new.save_csv(data, file_path)
  pp "File #{file_path} saved with full production enum data"
end

class GenerateEnumHelper
  def self.lookup_data
    sql = <<-SQL
        SELECT *, aa.attribute_name
        FROM assessment_attribute_lookups aal
        JOIN public.assessment_lookups al on aal.lookup_id = al.id
        JOIN public.assessment_attributes aa on aal.attribute_id = aa.attribute_id
    SQL

    ActiveRecord::Base.connection.exec_query(sql).to_a
  end
end
