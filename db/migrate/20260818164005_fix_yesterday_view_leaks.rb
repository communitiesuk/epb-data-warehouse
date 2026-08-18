class FixYesterdayViewLeaks < ActiveRecord::Migration[8.1]
  def self.domestic_sql
    <<~SQL
      SELECT
        ad.assessment_id AS CERTIFICATE_NUMBER,
        s.address_line_1 AS ADDRESS1,
        s.address_line_2 AS ADDRESS2,
        s.address_line_3 AS ADDRESS3,
        CONCAT_WS(', ', s.address_line_1, s.address_line_2, s.address_line_3) AS ADDRESS,
        s.postcode AS POSTCODE,
        ad.document ->> 'inspection_date' AS INSPECTION_DATE,
        s.uprn,
        ad.document ->> 'environmental_impact_potential' AS ENVIRONMENT_IMPACT_POTENTIAL,
        ad.document ->> 'energy_consumption_current' AS ENERGY_CONSUMPTION_CURRENT,
        ad.document ->> 'energy_consumption_potential' AS ENERGY_CONSUMPTION_POTENTIAL,
        ad.document ->> 'environmental_impact_current' AS ENVIRONMENT_IMPACT_CURRENT,
        ad.document ->> 'co2_emissions_current' AS CO2_EMISSIONS_CURRENT,
        ad.document ->> 'co2_emissions_current_per_floor_area' AS CO2_EMISS_CURR_PER_FLOOR_AREA,
        ad.document ->> 'co2_emissions_potential' AS CO2_EMISSIONS_POTENTIAL,
        ad.document ->> 'total_floor_area' AS TOTAL_FLOOR_AREA,
        TO_CHAR(s.registration_date, 'yyyy-mm-dd') AS LODGEMENT_DATE,
        ad.document ->> 'report_type' AS REPORT_TYPE,
        s.post_town AS POSTTOWN,
        to_char((ad.document ->> 'created_at')::timestamptz,'YYYY-MM-DD HH24:MI:SS') AS LODGEMENT_DATETIME,
        s.current_energy_efficiency_rating::VARCHAR AS CURRENT_ENERGY_EFFICIENCY,
        s.current_energy_efficiency_band AS CURRENT_ENERGY_RATING,
        ad.document ->> 'energy_rating_potential' AS POTENTIAL_ENERGY_EFFICIENCY,
        energy_band_calculator((ad.document ->> 'energy_rating_potential')::INTEGER, s.assessment_type) AS POTENTIAL_ENERGY_RATING,
        ad.document ->> 'extensions_count' AS EXTENSION_COUNT,
        COALESCE(
            ad.document ->> 'open_fireplaces_count',
            ad.document ->> 'open_chimneys_count',
            ad.document -> 'sap_ventilation' ->> 'open_chimneys_count',
            ad.document -> 'sap_ventilation' ->> 'open_fireplaces_count'
        ) AS NUMBER_OPEN_FIREPLACES,
        ad.document ->> 'heated_room_count' AS NUMBER_HEATED_ROOMS,
        ad.document ->> 'habitable_room_count' AS NUMBER_HABITABLE_ROOMS,
        COALESCE(
            (ad.document ->> 'low_energy_lighting')::TEXT,
            ad.document -> 'sap_energy_source' ->> 'low_energy_fixed_lighting_outlets_percentage',
            ROUND(
                sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count'], ad.assessment_id)
                / NULLIF(
                    (
                      sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count', 'incandescent_fixed_lighting_bulbs_count'], ad.assessment_id)
                    ),
                    0
                ) * 100
            )::TEXT,
            (
              SELECT
                  ROUND(
                      SUM(
                          CASE
                              WHEN (sl ->> 'lighting_efficacy')::FLOAT > 65 THEN (sl ->> 'lighting_outlets')::INTEGER
                              ELSE NULL
                          END
                      )::NUMERIC / NULLIF(SUM((sl ->> 'lighting_outlets')::FLOAT), 0) * 100
                  )::TEXT
              FROM
                  jsonb_array_elements(ad.document -> 'sap_lighting' -> 0) AS sl
            )
        ) AS LOW_ENERGY_LIGHTING,
        COALESCE(
          (ad.document ->> 'low_energy_fixed_lighting_outlets_count')::TEXT,
          ad.document -> 'sap_energy_source' ->> 'low_energy_fixed_lighting_outlets_count',
          (
            sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count'], ad.assessment_id)
          )::TEXT,
          (SELECT (SUM(
                      CASE
                        WHEN (sl ->> 'lighting_efficacy')::FLOAT > 65 THEN (sl ->> 'lighting_outlets')::INTEGER
                        ELSE NULL
                      END
                    ))::TEXT
             FROM jsonb_array_elements(ad.document -> 'sap_lighting' -> 0 ) AS sl
          )
        ) AS LOW_ENERGY_FIXED_LIGHTING_OUTLETS_COUNT,
        ad.document ->> 'solar_water_heating' AS SOLAR_WATER_HEATING_FLAG,
        get_lookup_value('mechanical_ventilation', ad.document ->> 'mechanical_ventilation', s.assessment_type, ad.document ->> 'schema_type') AS MECHANICAL_VENTILATION,
        get_lookup_value('tenure', ad.document ->> 'tenure', s.assessment_type, ad.document ->> 'schema_type') AS TENURE,
        get_lookup_value('property_type', ad.document ->> 'property_type', s.assessment_type, ad.document ->> 'schema_type') AS PROPERTY_TYPE,
        get_lookup_value('transaction_type', ad.document ->> 'transaction_type', s.assessment_type, ad.document ->> 'schema_type') AS TRANSACTION_TYPE,
        fn_construction_age_band((ad.document)::jsonb, s.assessment_type, (ad.document ->> 'schema_type')::varchar) as CONSTRUCTION_AGE_BAND,
        get_lookup_value('built_form', ad.document ->> 'built_form', s.assessment_type, ad.document ->> 'schema_type') AS BUILT_FORM,
        CASE
          WHEN s.assessment_type = 'RdSAP'
          THEN get_lookup_value('energy_tariff', ad.document -> 'sap_energy_source' ->> 'meter_type', s.assessment_type, ad.document ->> 'schema_type')
          ELSE get_lookup_value('energy_tariff', ad.document -> 'sap_energy_source' ->> 'electricity_tariff', s.assessment_type, ad.document ->> 'schema_type')
        END AS ENERGY_TARIFF,
        get_lookup_value('glazed_type',
            COALESCE(ad.document ->> 'multiple_glazing_type', ad.document ->> 'double_glazing_installed'),#{' '}
            s.assessment_type, ad.document ->> 'schema_type') AS GLAZED_TYPE,
        get_lookup_value('glazed_area', ad.document ->> 'glazed_area', s.assessment_type, ad.document ->> 'schema_type') AS GLAZED_AREA,
        get_lookup_value('heat_loss_corridor', ad.document -> 'sap_flat_details' ->> 'heat_loss_corridor', s.assessment_type, ad.document ->> 'schema_type') AS HEAT_LOSS_CORRIDOR,
        get_lookup_value('main_fuel',COALESCE(ad.document -> 'sap_heating' ->> 'main_fuel_type', ad.document -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type'), s.assessment_type, ad.document ->> 'schema_type') AS MAIN_FUEL,
        COALESCE(ad.document -> 'sap_flat_details' -> 'unheated_corridor_length' ->> 'value', ad.document -> 'sap_flat_details' ->> 'unheated_corridor_length') AS UNHEATED_CORRIDOR_LENGTH,
        ad.document -> 'sap_flat_details' ->> 'level' AS FLOOR_LEVEL,
        COALESCE(ad.document -> 'sap_flat_details' ->> 'top_storey',
        CASE
          WHEN ad.document -> 'sap_flat_details' ->> 'level' = '3'
          THEN 'Y'
          ELSE 'N'
        END) AS FLAT_TOP_STOREY,
        jsonb_array_length(ad.document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions') AS FLAT_STOREY_COUNT,
        COALESCE(ad.document -> 'sap_energy_source' ->> 'mains_gas',ad.document -> 'sap_energy_source' ->> 'main_gas') AS MAINS_GAS_FLAG,
        COALESCE(ad.document -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area', ad.document -> 'sap_energy_source' -> 'photovoltaic_supply' ->> 'percent_roof_area', ad.document ->> 'photovoltaic_supply' ) AS PHOTO_SUPPLY,
        COALESCE((ad.document -> 'sap_energy_source' ->> 'wind_turbines_count')::INTEGER, jsonb_array_length(ad.document -> 'sap_energy_source' -> 'wind_turbines')) AS WIND_TURBINE_COUNT,
        COALESCE(ad.document -> 'lighting_cost_current' ->> 'value', ad.document ->> 'lighting_cost_current') AS LIGHTING_COST_CURRENT,
        COALESCE(ad.document -> 'lighting_cost_potential' ->> 'value', ad.document ->> 'lighting_cost_potential') AS LIGHTING_COST_POTENTIAL,
        COALESCE(ad.document -> 'heating_cost_current' ->> 'value', ad.document ->> 'heating_cost_current') AS HEATING_COST_CURRENT,
        COALESCE(ad.document -> 'heating_cost_potential' ->> 'value', ad.document ->> 'heating_cost_potential') AS HEATING_COST_POTENTIAL,
        COALESCE(ad.document -> 'hot_water_cost_current' ->> 'value', ad.document ->> 'hot_water_cost_current') AS HOT_WATER_COST_CURRENT,
        COALESCE(ad.document -> 'hot_water_cost_potential' ->> 'value', ad.document ->> 'hot_water_cost_potential') AS HOT_WATER_COST_POTENTIAL,
        COALESCE(ad.document ->> 'multiple_glazed_percentage', ad.document ->> 'multiple_glazed_proportion', ad.document ->> 'double_glazed_proportion') AS MULTI_GLAZE_PROPORTION,
        fn_clean_description(COALESCE(ad.document -> 'hot_water' -> 'description' ->> 'value', ad.document -> 'hot_water' ->> 'description')::varchar) AS HOTWATER_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'hot_water' ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS HOT_WATER_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'hot_water' ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS HOT_WATER_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'floors' -> 0 -> 'description' ->> 'value', ad.document -> 'floors' -> 0 ->> 'description')::varchar) AS FLOOR_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'floors' -> 0 ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS FLOOR_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'floors' -> 0 ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS FLOOR_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'roofs' -> 0 -> 'description' ->> 'value', ad.document -> 'roofs' -> 0 ->> 'description')::varchar) AS ROOF_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'roofs' -> 0 ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS ROOF_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'roofs' -> 0 ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS ROOF_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'walls' -> 0 -> 'description' ->> 'value', ad.document -> 'walls' -> 0 ->> 'description')::varchar) AS WALLS_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'walls' -> 0 ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS WALLS_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'walls' -> 0 ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS WALLS_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'window' ->> 'description', ad.document -> 'window' -> 0 ->> 'description', ad.document -> 'windows' ->> 'description', ad.document -> 'windows' -> 0 ->> 'description')::varchar) AS WINDOWS_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', COALESCE(
                                                      ad.document -> 'window' ->> 'energy_efficiency_rating',
                                                      ad.document -> 'window' -> 0 ->> 'energy_efficiency_rating',
                                                      ad.document -> 'windows' ->> 'energy_efficiency_rating',
                                                      ad.document -> 'windows' -> 0 ->> 'energy_efficiency_rating'
                                                    ),
          s.assessment_type, ad.document ->> 'schema_type') AS WINDOWS_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', COALESCE(
                                                      ad.document -> 'window' ->> 'environmental_efficiency_rating',
                                                      ad.document -> 'windows' ->> 'environmental_efficiency_rating',
                                                      ad.document -> 'window' -> 0 ->> 'environmental_efficiency_rating',
                                                      ad.document -> 'windows' -> 0 ->> 'environmental_efficiency_rating'
                                                    ),
          s.assessment_type, ad.document ->> 'schema_type') AS WINDOWS_ENV_EFF,
        COALESCE(ad.document -> 'secondary_heating' -> 'description' ->> 'value', ad.document -> 'secondary_heating' ->> 'description') AS SECONDHEAT_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'secondary_heating' ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS SHEATING_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'secondary_heating' ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS SHEATING_ENV_EFF,
        (SELECT fn_clean_description(COALESCE(STRING_AGG((mh -> 'description' ->> 'value')::TEXT, ', '), STRING_AGG((mh ->> 'description')::TEXT, ', '))::varchar) AS MAINHEAT_DESCRIPTION
        FROM jsonb_array_elements(ad.document -> 'main_heating') AS mh),
        get_lookup_value('energy_efficiency_rating', ad.document -> 'main_heating' -> 0 ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS MAINHEAT_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'main_heating' -> 0 ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS MAINHEAT_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'main_heating_controls' -> 0 -> 'description' ->> 'value', ad.document -> 'main_heating_controls' -> 0 ->> 'description')::varchar) AS MAINHEATCONT_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'main_heating_controls' -> 0 ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS MAINHEATC_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'main_heating_controls' -> 0 ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS MAINHEATC_ENV_EFF,
        fn_clean_description(COALESCE(ad.document -> 'lighting' -> 'description' ->> 'value', ad.document -> 'lighting' ->> 'description')::varchar) AS LIGHTING_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'lighting' ->> 'energy_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS LIGHTING_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', ad.document -> 'lighting' ->> 'environmental_efficiency_rating', s.assessment_type, ad.document ->> 'schema_type') AS LIGHTING_ENV_EFF,
        COALESCE(
          ad.document ->> 'fixed_lighting_outlets_count',
          ad.document -> 'sap_energy_source' ->> 'fixed_lighting_outlets_count',
          (
            sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count', 'incandescent_fixed_lighting_bulbs_count'], ad.assessment_id)
          )::TEXT,
          (SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::INTEGER, 0))::INTEGER)::TEXT
                FROM jsonb_array_elements(ad.document -> 'sap_lighting' -> 0) AS sl)
        ) AS FIXED_LIGHTING_OUTLETS_COUNT,
        COALESCE(ad.document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions' -> 0 -> 'room_height' ->> 'value', ad.document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'storey_height', ad.document -> 'sap_building_parts' -> 0 ->> 'room_height', ad.document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'room_height') AS FLOOR_HEIGHT,
        fn_clean_description(COALESCE(ad.document -> 'main_heating_controls' -> 0 -> 'description' ->> 'value', ad.document -> 'main_heating_controls' -> 0 ->> 'description')::varchar) AS MAIN_HEATING_CONTROLS,
        ons.local_authority_code AS LOCAL_AUTHORITY,
        s.council AS LOCAL_AUTHORITY_LABEL,
        s.constituency AS CONSTITUENCY_LABEL,
        os_p.area_code AS CONSTITUENCY,
        co.country_name AS COUNTRY,
        ons.region_code AS REGION,
       fn_uprn_source((ad.document ->> 'assessment_address_id')::varchar, matched_uprn ) as UPRN_SOURCE
      FROM assessment_documents AS ad
      JOIN assessment_search AS s ON s.assessment_id = ad.assessment_id
      JOIN ( VALUES ('SAP'), ('RdSAP') ) AS vals (t) ON (assessment_type = t)
      JOIN assessments_country_ids AS aci ON ad.assessment_id = aci.assessment_id
      JOIN countries AS co ON aci.country_id = co.country_id
      LEFT JOIN ons_postcode_directory AS ons ON s.postcode = ons.postcode
      LEFT JOIN ons_postcode_directory_names AS os_p ON ons.westminster_parliamentary_constituency_code = os_p.area_code
      WHERE  co.country_code IN ('EAW', 'ENG', 'WLS')
    SQL
  end

  def self.commercial_sql
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
        CONCAT_WS(', ', s.address_line_1, s.address_line_2, s.address_line_3) AS address,
        s.council AS LOCAL_AUTHORITY_LABEL,
        s.constituency AS CONSTITUENCY_LABEL,
        get_attribute_value('post_town', ad.assessment_id) AS POSTTOWN,
        to_char((document ->> 'created_at')::timestamptz,'YYYY-MM-DD HH24:MI:SS') AS LODGEMENT_DATETIME,
        get_attribute_json('energy_use', ad.assessment_id) ->> 'energy_consumption_current' AS PRIMARY_ENERGY_VALUE,
        get_attribute_value('report_type', ad.assessment_id) AS REPORT_TYPE,
        fn_uprn_source((document ->> 'assessment_address_id')::varchar, matched_uprn ) as UPRN_SOURCE
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
      WHERE  co.country_code IN ('EAW', 'ENG', 'WLS')
    SQL
  end

  def self.dec_sql
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
        s.constituency AS CONSTITUENCY_LABEL,
        fn_uprn_source((document ->> 'assessment_address_id')::varchar, matched_uprn ) as UPRN_SOURCE
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
      WHERE co.country_code IN ('EAW', 'ENG', 'WLS')
    SQL
  end

  def self.up
    execute "DROP VIEW IF EXISTS vw_domestic_yesterday"
    execute "CREATE VIEW vw_domestic_yesterday AS
    #{domestic_sql} AND (s.created_at::date = (CURRENT_DATE - 1) OR EXISTS(SELECT * FROM audit_logs l WHERE s.assessment_id=l.assessment_id AND event_type = 'address_id_updated' AND timestamp::date = (CURRENT_DATE - 1)))"

    execute "DROP VIEW IF EXISTS vw_commercial_yesterday"
    execute "CREATE VIEW vw_commercial_yesterday AS
      #{commercial_sql} AND (s.created_at::date = (CURRENT_DATE - 1) OR EXISTS(SELECT * FROM audit_logs l WHERE s.assessment_id=l.assessment_id AND event_type = 'address_id_updated' AND timestamp::date = (CURRENT_DATE - 1)))"

    execute "DROP VIEW IF EXISTS vw_dec_yesterday"
    execute "CREATE VIEW vw_dec_yesterday AS
      #{dec_sql} AND (s.created_at::date = (CURRENT_DATE - 1) OR EXISTS(SELECT * FROM audit_logs l WHERE s.assessment_id=l.assessment_id AND event_type = 'address_id_updated' AND timestamp::date = (CURRENT_DATE - 1)))"
  end

  def self.down; end
end
