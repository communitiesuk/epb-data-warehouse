class AddUprnSourceNonDomesticViews < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
      SELECT
        ad.assessment_id AS CERTIFICATE_NUMBER,
        get_attribute_value('address_line_1', ad.assessment_id) AS ADDRESS1,
        get_attribute_value('address_line_2', ad.assessment_id) AS ADDRESS2,
        get_attribute_value('address_line_3', ad.assessment_id) AS ADDRESS3,
        get_attribute_value('postcode', ad.assessment_id)::VARCHAR AS POSTCODE,
        s.uprn,
        get_attribute_value('asset_rating', ad.assessment_id) AS ASSET_RATING,
        energy_band_calculator(get_attribute_value('asset_rating', ad.assessment_id)::INTEGER, 'cepc') AS ASSET_RATING_BAND,
        get_attribute_value('property_type', ad.assessment_id) AS PROPERTY_TYPE,
        get_attribute_value('inspection_date', ad.assessment_id) AS INSPECTION_DATE,
        ons.local_authority_code AS LOCAL_AUTHORITY,
        os_la.area_code AS CONSTITUENCY,
        get_lookup_value('transaction_type', get_attribute_value('transaction_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id) ) AS TRANSACTION_TYPE,
        get_attribute_value('registration_date', ad.assessment_id) AS LODGEMENT_DATE,
        get_attribute_value('new_build_benchmark', ad.assessment_id) AS NEW_BUILD_BENCHMARK,
        get_attribute_value('existing_stock_benchmark', ad.assessment_id) AS EXISTING_STOCK_BENCHMARK,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'building_level' AS BUILDING_LEVEL,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'main_heating_fuel' AS MAIN_HEATING_FUEL,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'other_fuel_description' AS OTHER_FUEL_DESC,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'special_energy_uses' AS SPECIAL_ENERGY_USES,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'renewable_sources' AS RENEWABLE_SOURCES,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'floor_area' AS FLOOR_AREA,
        get_attribute_value('ser', ad.assessment_id) AS STANDARD_EMISSIONS,
        get_attribute_value('ter', ad.assessment_id) AS TARGET_EMISSIONS,
        get_attribute_value('tyr', ad.assessment_id) AS TYPICAL_EMISSIONS,
        get_attribute_value('ber', ad.assessment_id) AS BUILDING_EMISSIONS,
        get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_present' AS AIRCON_PRESENT,
        CASE
          WHEN (get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_rating_unknown_flag')::INT = 1
          THEN ''
          ELSE get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_kw_rating'
        END AS AIRCON_KW_RATING,
        get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_estimated_output' AS ESTIMATED_AIRCON_KW_RATING,
        get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_inspection_commissioned' AS AC_INSPECTION_COMMISSIONED,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'building_environment' AS BUILDING_ENVIRONMENT,
        get_attribute_value('address_line_1', ad.assessment_id) AS ADDRESS,
        s.council AS LOCAL_AUTHORITY_LABEL,
        s.constituency AS CONSTITUENCY_LABEL,
        get_attribute_value('post_town', ad.assessment_id) AS POSTTOWN,
        get_attribute_value('created_at', ad.assessment_id)::TIMESTAMP AS LODGEMENT_DATETIME,
        get_attribute_json('energy_use', ad.assessment_id) ->> 'energy_consumption_current' AS PRIMARY_ENERGY_VALUE,
        get_attribute_value('report_type', ad.assessment_id) AS REPORT_TYPE,
        fn_uprn_source((document ->> 'assessment_address_id')::varchar, matched_uprn ) as UPRN_SOURCE
      #{'      '}
      FROM assessment_documents ad
      JOIN assessment_search AS s ON s.assessment_id = ad.assessment_id
      JOIN ( VALUES ('CEPC')) AS vals (t) ON (assessment_type = t)
      JOIN (
         SELECT ad2.assessment_id as assessment_id, ad2.document ->> 'assessment_type' AS ASSESSMENT_TYPE
         FROM assessment_documents ad2
      ) AS t
      ON t.assessment_id = ad.assessment_id
      JOIN assessments_country_ids aci ON ad.assessment_id = aci.assessment_id
      JOIN countries co ON aci.country_id = co.country_id
      LEFT JOIN ons_postcode_directory ons ON s.postcode = ons.postcode
      LEFT JOIN ons_postcode_directory_names AS os_la ON ons.westminster_parliamentary_constituency_code = os_la.area_code
    SQL
  end

  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_commercial_search"
    execute "CREATE MATERIALIZED VIEW mvw_commercial_search AS
    #{sql} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_commercial_yesterday"
    execute "CREATE VIEW vw_commercial_yesterday AS
    #{sql} WHERE s.created_at::date = (CURRENT_DATE - 1) OR updated_at::date = (CURRENT_DATE - 1)"
  end

  def self.down; end
end
