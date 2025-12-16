class FixDataPointsOnMvwDecSearchAndVwDecYesterday < ActiveRecord::Migration[7.0]
  def self.sql
    <<~SQL
      SELECT
        ad.assessment_id AS CERTIFICATE_NUMBER,
        s.address_line_1 AS ADDRESS1,
        s.address_line_2 AS ADDRESS2,
        s.address_line_3 AS ADDRESS3,
        CONCAT_WS(', ', s.address_line_1, s.address_line_2, s.address_line_3) AS ADDRESS,
        s.post_town AS POSTTOWN,
        s.postcode AS POSTCODE,
        s.uprn,
        get_attribute_json('this_assessment',  ad.assessment_id) ->> 'energy_rating' AS CURRENT_OPERATIONAL_RATING,
        get_attribute_json('year1_assessment',  ad.assessment_id) ->> 'energy_rating' AS YR1_OPERATIONAL_RATING,
        get_attribute_json('year2_assessment',  ad.assessment_id) ->> 'energy_rating' AS YR2_OPERATIONAL_RATING,
        get_attribute_json('this_assessment',  ad.assessment_id) ->> 'electricity_co2' AS ELECTRIC_CO2,
        get_attribute_json('this_assessment',  ad.assessment_id) ->> 'heating_co2' AS HEATING_CO2,
        get_attribute_json('this_assessment',  ad.assessment_id) ->> 'renewables_co2' AS RENEWABLES_CO2,
        get_attribute_value('property_type', ad.assessment_id) AS PROPERTY_TYPE,
        get_attribute_value('inspection_date', ad.assessment_id) AS INSPECTION_DATE,
        get_attribute_value('registration_date', ad.assessment_id) AS LODGEMENT_DATE,
        get_attribute_value('created_at', ad.assessment_id)::TIMESTAMP AS LODGEMENT_DATETIME,
        get_attribute_json('or_benchmark_data',  ad.assessment_id) ->> 'main_benchmark' AS MAIN_BENCHMARK,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'main_heating_fuel' AS MAIN_HEATING_FUEL,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'special_energy_uses' AS SPECIAL_ENERGY_USES,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'renewable_sources' AS RENEWABLE_SOURCES,
        ROUND(
          (get_attribute_json('technical_information',  ad.assessment_id)
              ->> 'floor_area')::NUMERIC
        )::INTEGER AS TOTAL_FLOOR_AREA,
        get_attribute_json('or_benchmark_data',  ad.assessment_id) -> 'benchmarks' -> 0 ->> 'occupancy_level' AS OCCUPANCY_LEVEL,
        ROUND(
          (get_attribute_json('dec_annual_energy_summary', ad.assessment_id)
              ->> 'annual_energy_use_fuel_thermal')::NUMERIC
        )::INTEGER AS ANNUAL_THERMAL_FUEL_USAGE,
        ROUND(
          (get_attribute_json('dec_annual_energy_summary',  ad.assessment_id)
              ->> 'typical_thermal_use')::NUMERIC
        )::INTEGER AS TYPICAL_THERMAL_FUEL_USAGE,
        ROUND(
          (get_attribute_json('dec_annual_energy_summary', ad.assessment_id)
              ->> 'annual_energy_use_electrical')::NUMERIC
        )::INTEGER AS ANNUAL_ELECTRICAL_FUEL_USAGE,
        ROUND(
          (get_attribute_json('dec_annual_energy_summary',  ad.assessment_id)
              ->> 'typical_thermal_use')::NUMERIC
        )::INTEGER AS TYPICAL_THERMAL_USE,
        get_attribute_json('dec_annual_energy_summary',  ad.assessment_id) ->> 'typical_electrical_use' AS TYPICAL_ELECTRICAL_FUEL_USAGE,
        get_attribute_json('dec_annual_energy_summary',  ad.assessment_id) ->> 'renewables_fuel_thermal' AS RENEWABLES_FUEL_THERMAL,
        get_attribute_json('dec_annual_energy_summary',  ad.assessment_id) ->> 'renewables_electrical' AS RENEWABLES_ELECTRICAL,
        get_attribute_json('year1_assessment',  ad.assessment_id) ->> 'electricity_co2' AS YR1_ELECTRICITY_CO2,
        get_attribute_json('year2_assessment',  ad.assessment_id) ->> 'electricity_co2' AS YR2_ELECTRICITY_CO2,
        get_attribute_json('year1_assessment',  ad.assessment_id) ->> 'heating_co2' AS YR1_HEATING_CO2,
        get_attribute_json('year2_assessment',  ad.assessment_id) ->> 'heating_co2' AS YR2_HEATING_CO2,
        get_attribute_json('year1_assessment',  ad.assessment_id) ->> 'renewables_co2' AS YR1_RENEWABLES_CO2,
        get_attribute_json('year2_assessment',  ad.assessment_id) ->> 'renewables_co2' AS YR2_RENEWABLES_CO2,
        CASE get_attribute_json('ac_questionnaire', ad.assessment_id) ->> 'ac_present'
          WHEN 'Yes' THEN 'Y'
          WHEN 'No'  THEN 'N'
          ELSE NULL
        END AS AIRCON_PRESENT,
        CASE
          WHEN (get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_rating_unknown_flag') IN ('1', 'true')
          THEN ''
          ELSE get_attribute_json('ac_questionnaire', ad.assessment_id) -> 'ac_rated_output' ->> 'ac_kw_rating'
        END AS AIRCON_KW_RATING,
        get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_estimated_output' AS ESTIMATED_AIRCON_KW_RATING,
        get_attribute_json('ac_questionnaire',  ad.assessment_id) ->> 'ac_inspection_commissioned' AS AC_INSPECTION_COMMISSIONED,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'building_environment' AS BUILDING_ENVIRONMENT,
        get_attribute_value('building_category', ad.assessment_id) AS BUILDING_CATEGORY,
        energy_band_calculator((get_attribute_json('this_assessment',  ad.assessment_id) -> 'energy_rating')::INTEGER, ad.document ->> 'assessment_type') AS OPERATIONAL_RATING_BAND,
        get_attribute_json('this_assessment',  ad.assessment_id) ->> 'nominated_date' AS NOMINATED_DATE,
        get_attribute_value('or_assessment_end_date', ad.assessment_id) AS OR_ASSESSMENT_END_DATE,
        get_attribute_value('report_type', ad.assessment_id) AS REPORT_TYPE,
        get_attribute_json('technical_information',  ad.assessment_id) ->> 'other_fuel_description' AS OTHER_FUEL,
        co.country_name AS COUNTRY,
        ons.local_authority_code AS LOCAL_AUTHORITY,
        s.council AS LOCAL_AUTHORITY_LABEL,
        os_la.area_code AS CONSTITUENCY,
        s.constituency AS CONSTITUENCY_LABEL
      FROM assessment_documents ad
      JOIN assessment_search AS s ON s.assessment_id = ad.assessment_id
      JOIN ( VALUES ('DEC')) AS vals (t) ON (assessment_type = t)
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
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_dec_search"
    execute "CREATE MATERIALIZED VIEW mvw_dec_search AS
    #{sql} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_dec_yesterday"
    execute "CREATE VIEW vw_dec_yesterday AS
    #{sql} WHERE s.created_at::date = (CURRENT_DATE - 1) OR updated_at::date = (CURRENT_DATE - 1)"
  end

  def self.down; end
end
