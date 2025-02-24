require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe Gateway::CommercialSearchGateway do
  subject(:gateway) { described_class.new }

  context "when creating commercial materialized view" do
    include_context "when lodging XML"
    include_context "when saving ons data"
    include_context "when exporting data"
    before do
      import_postcode_directory_name
      import_postcode_directory_data
      config_path = "spec/config/attribute_enum_search_map.json"
      config_gateway = Gateway::XsdConfigGateway.new(config_path)
      import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
      import_use_case.execute

      add_countries
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc")
    end

    let(:expected_data) do
      { "assessment_id" => "0000-0000-0000-0000-0006",
        "address1" => "60 Maple Syrup Road",
        "address2" => "Candy Mountain",
        "postcode" => "NE0 0AA",
        "property_type" => "A1/A2 Retail and Financial/Professional services",
        "asset_rating" => "84",
        "building_reference_number" => "UPRN-000000000000",
        "asset_rating_band" => "D",
        "inspection_date" => "2021-03-19",
        "lodgement_date" => "2021-03-19",
        "transaction_type" => "1",
        "building_level" => nil,
        "existing_stock_benchmark" => "100",
        "main_heating_fuel" => nil,
        "new_build_benchmark" => "34",
        "aircon_present" => nil,
        "building_emissions" => nil,
        "floor_area" => nil,
        "lodgement_datetime" => Time.parse("2021-03-19 00:00:00.000000000 +0000"),
        "other_fuel_desc" => nil,
        "renewable_sources" => nil,
        "special_energy_uses" => nil,
        "standard_emissions" => nil,
        "target_emissions" => nil,
        "typical_emissions" => nil,
        "building_environment" => nil,
        "country" => "England",
        "primary_energy_value" => nil,
        "report_type" => "3",
        "type_of_assessment" => "CEPC" }
    end
    let(:first_query_result) do
      ActiveRecord::Base.connection.exec_query("SELECT
      get_attribute_value('postcode', aav.assessment_id) as postcode,
      get_attribute_value('property_type', aav.assessment_id) as property_type,
      get_attribute_value('address_line_1', aav.assessment_id) as address1,
      get_attribute_value('address_line_2', aav.assessment_id) as address2,
      get_attribute_value('uprn', aav.assessment_id) as building_reference_number,
      get_attribute_value('asset_rating', aav.assessment_id) as asset_rating,
      energy_band_calculator(get_attribute_value('asset_rating', aav.assessment_id)::INTEGER, 'cepc') as asset_rating_band,
      get_attribute_value('property_type', aav.assessment_id) as property_type,
      get_attribute_value('registration_date', aav.assessment_id) as lodgement_date,
      get_attribute_value('registration_date', aav.assessment_id)::TIMESTAMP as lodgement_datetime,
      get_attribute_value('inspection_date', aav.assessment_id) as inspection_date,
      get_attribute_value('transaction_type', aav.assessment_id) as transaction_type,
      get_attribute_value('new_build_benchmark', aav.assessment_id) as new_build_benchmark,
      get_attribute_value('existing_stock_benchmark', aav.assessment_id) as existing_stock_benchmark,
      get_attribute_value('building_level', aav.assessment_id) as building_level,
      get_attribute_value('main_heating_fuel', aav.assessment_id) as main_heating_fuel,
      get_attribute_value('other_fuel_desc', aav.assessment_id) as other_fuel_desc,
      get_attribute_value('special_energy_uses', aav.assessment_id) as special_energy_uses,
      get_attribute_value('renewable_energy_source', aav.assessment_id) as renewable_sources,
      get_attribute_value('total_floor_area', aav.assessment_id) as floor_area,
      get_attribute_value('emission_rate_type', aav.assessment_id) as standard_emissions,
      get_attribute_value('emission_rate_type', aav.assessment_id) as target_emissions,
      get_attribute_value('emission_rate_type', aav.assessment_id) as typical_emissions,
      get_attribute_value('emission_rate_type', aav.assessment_id) as building_emissions,
      get_attribute_value('emission_rate_type', aav.assessment_id) as standard_emissions,
      get_attribute_value('ac_questionnaire',  aav.assessment_id) as aircon_present,
      get_attribute_value('emission_rate_type', aav.assessment_id) as standard_emissions,
      get_attribute_value('building_environment', aav.assessment_id) as building_environment,
      get_attribute_value('report_type', aav.assessment_id) as report_type,
      t.assessment_type as type_of_assessment,
      get_attribute_value('primary_energy_value', aav.assessment_id) as primary_energy_value,
      co.country_name as country,

      aav.assessment_id as assessment_id
FROM assessment_attribute_values aav
JOIN (SELECT aav2.assessment_id, aav2.attribute_value as assessment_type
                       FROM assessment_attribute_values aav2
                       JOIN public.assessment_attributes a2 on aav2.attribute_id = a2.attribute_id
                       WHERE a2.attribute_name = 'assessment_type')  as t
                      ON t.assessment_id = aav.assessment_id
join assessments_country_ids aci on aav.assessment_id = aci.assessment_id
join countries co on aci.country_id = co.country_id
AND t.assessment_type = 'CEPC'
  AND co.country_code IN ('EAW', 'ENG', 'WLS');").first
    end

    it "creates a table with the required data" do
      expect(first_query_result).to eq expected_data
    end
  end
end
