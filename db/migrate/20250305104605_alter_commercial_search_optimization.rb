class AlterCommercialSearchOptimization < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_commercial_search"
    execute "CREATE MATERIALIZED VIEW mvw_commercial_search
    AS
    SELECT DISTINCT
          get_attribute_value('postcode', ad.assessment_id) as postcode,
          get_attribute_value('post_town', ad.assessment_id) as posttown,
          get_attribute_value('property_type', ad.assessment_id) as property_type,
          get_attribute_value('address_line_1', ad.assessment_id) as address1,
          get_attribute_value('address_line_2', ad.assessment_id) as address2,
          get_attribute_value('address_line_3', ad.assessment_id) as address3,
          get_attribute_value('uprn', ad.assessment_id) as building_reference_number,
          get_attribute_value('asset_rating', ad.assessment_id) as asset_rating,
          energy_band_calculator(get_attribute_value('asset_rating', ad.assessment_id)::INTEGER, 'cepc') as asset_rating_band,
          get_attribute_value('registration_date', ad.assessment_id) as lodgement_date,
          get_attribute_value('registration_date', ad.assessment_id)::TIMESTAMP as lodgement_datetime,
          get_attribute_value('inspection_date', ad.assessment_id) as inspection_date,
          get_lookup_value('transaction_type', get_attribute_value('transaction_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id) )  as transaction_type,
          get_attribute_value('new_build_benchmark', ad.assessment_id) as new_build_benchmark,
          get_attribute_value('existing_stock_benchmark', ad.assessment_id) as existing_stock_benchmark,

          get_attribute_json('technical_information',  ad.assessment_id) ->> 'floor_area' as floor_area,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'building_level' as building_level,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'main_heating_fuel' as main_heating_fuel,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'building_environment' as building_environment,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'other_fuel_description' as other_fuel_desc,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'special_energy_uses' as special_energy_uses,
          get_attribute_json('technical_information',  ad.assessment_id) ->> 'renewable_sources' as renewable_sources,

          get_attribute_value('ser', ad.assessment_id) as standard_emissions,
          get_attribute_value('ter', ad.assessment_id) as target_emissions,
          get_attribute_value('tyr', ad.assessment_id) as typical_emissions,
          get_attribute_value('ber', ad.assessment_id) as building_emissions,
          get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_present' as aircon_present,
          CASE
            WHEN (get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_rating_unknown_flag')::int = 1
            THEN 'Unknown'
            ELSE get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_kw_rating'
          END as aircon_kw_rating,
          get_lookup_value('ac_inspection_commissioned', get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_inspection_commissioned', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id) )  as ac_inspection_commissioned,
          get_lookup_value('ac_estimated_output', get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_estimated_output', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id) )  as estimated_aircon_kw_rating,

          get_lookup_value('report_type', get_attribute_value('report_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id) )  as report_type,
          t.assessment_type as type_of_assessment,
          get_attribute_json('energy_use', ad.assessment_id) ->> 'energy_consumption_current' as primary_energy_value,
          co.country_name as country,
          ons_r.name as region,
          os_la.id::integer as council_id,
          ad.assessment_id as rrn

    FROM assessment_documents ad
    JOIN (
       SELECT ad2.assessment_id as assessment_id, ad2.document ->> 'assessment_type' as assessment_type
       FROM assessment_documents ad2
    ) AS t
    ON t.assessment_id = ad.assessment_id
    join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
    join countries co on aci.country_id = co.country_id
    left JOIN ons_postcode_directory ons on document ->> 'postcode' = ons.postcode
    left join ons_postcode_directory_names os_la on ons.local_authority_code = os_la.area_code
    LEFT JOIN ons_postcode_directory_names ons_r on ons.region_code = ons_r.area_code
    WHERE ad.document ->> 'assessment_type' = 'CEPC'
      AND co.country_code IN ('EAW', 'ENG', 'WLS')
      AND ons_r.type = 'Region'
    WITH NO DATA;"

    add_index :mvw_commercial_search, :rrn, unique: true
    add_index :mvw_commercial_search, :lodgement_date
    add_index :mvw_commercial_search, :council_id
  end

  def self.down; end
end
