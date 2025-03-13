require "csv"

namespace :one_off do
  desc "seed all data required for materialized views and refresh them"
  task :seed_materialized_views do
    Tasks::TaskHelpers.quit_if_production
    SeedMaterializedViewsHelper.import_postcode_directory_data
    SeedMaterializedViewsHelper.import_postcode_directory_name
    SeedMaterializedViewsHelper.import_countries
    SeedMaterializedViewsHelper.import_domestic_search_enums

    mv_gateway = Gateway::MaterializedViewsGateway.new
    mv_gateway.fetch_all.each do |mv_view|
      mv_gateway.refresh(name: mv_view)
    end
  end
end

class SeedMaterializedViewsHelper
  class Countries < ActiveRecord::Base
  end

  class OnsPostcodeDirectory < ActiveRecord::Base
  end

  def self.import_countries
    file_path = File.join Dir.pwd, "spec/config/countries.json"
    country_values = JSON.parse(File.read(file_path), symbolize_names: true)
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE countries RESTART IDENTITY CASCADE", "SQL")
    country_values.each do |item|
      Countries.create(country_id: item[:country_id], country_name: item[:country_name], address_base_country_code: item[:address_base_country_code], country_code: item[:country_code])
    end
  end

  def self.import_postcode_directory_data
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory.csv"
    ActiveRecord::Base.connection.execute("TRUNCATE ons_postcode_directory")
    CSV.foreach(file_path, headers: true) do |row|
      sql = "INSERT INTO ons_postcode_directory(postcode,country_code,region_code,local_authority_code,westminster_parliamentary_constituency_code,other_areas)
            VALUES ('#{row['postcode']}','#{row['country_code']}','#{row['region_code']}', '#{row['local_authority_code']}', '#{row['westminster_parliamentary_constituency_code']}','#{row['other_areas']}' )"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def self.import_postcode_directory_name
    file_path = File.join Dir.pwd, "spec/fixtures/ons_data/ons_postcode_directory_names.csv"
    ActiveRecord::Base.connection.execute("TRUNCATE ons_postcode_directory_names RESTART IDENTITY CASCADE")
    CSV.foreach(file_path, headers: true) do |row|
      sql = "INSERT INTO ons_postcode_directory_names(area_code,name,type,type_code)
        VALUES ('#{row['area_code']}', '#{row['name']}', '#{row['type']}', '#{row['type_code']}')"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def self.import_domestic_search_enums
    config_path = "spec/config/attribute_enum_search_map.json"
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
    import_use_case.execute
  end
end
