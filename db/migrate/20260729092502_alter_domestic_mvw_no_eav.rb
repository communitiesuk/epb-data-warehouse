class AlterDomesticMvwNoEav < ActiveRecord::Migration[8.1]
  def self.sql
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
        get_lookup_value('glazed_type', ad.document ->> 'multiple_glazing_type', s.assessment_type, ad.document ->> 'schema_type') AS GLAZED_TYPE,
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
        COALESCE(ad.document -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area', ad.document -> 'sap_energy_source' -> 'photovoltaic_supply' ->> 'percent_roof_area') AS PHOTO_SUPPLY,
        COALESCE((ad.document -> 'sap_energy_source' ->> 'wind_turbines_count')::INTEGER, jsonb_array_length(ad.document -> 'sap_energy_source' -> 'wind_turbines')) AS WIND_TURBINE_COUNT,
        COALESCE(ad.document -> 'lighting_cost_current' ->> 'value', ad.document ->> 'lighting_cost_current') AS LIGHTING_COST_CURRENT,
        COALESCE(ad.document -> 'lighting_cost_potential' ->> 'value', ad.document ->> 'lighting_cost_potential') AS LIGHTING_COST_POTENTIAL,
        COALESCE(ad.document -> 'heating_cost_current' ->> 'value', ad.document ->> 'heating_cost_current') AS HEATING_COST_CURRENT,
        COALESCE(ad.document -> 'heating_cost_potential' ->> 'value', ad.document ->> 'heating_cost_potential') AS HEATING_COST_POTENTIAL,
        COALESCE(ad.document -> 'hot_water_cost_current' ->> 'value', ad.document ->> 'hot_water_cost_current') AS HOT_WATER_COST_CURRENT,
        COALESCE(ad.document -> 'hot_water_cost_potential' ->> 'value', ad.document ->> 'hot_water_cost_potential') AS HOT_WATER_COST_POTENTIAL,
        COALESCE(ad.document ->> 'multiple_glazed_percentage', ad.document ->> 'multiple_glazed_proportion') AS MULTI_GLAZE_PROPORTION,
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

  def self.up
    execute "DROP VIEW IF EXISTS vw_domestic_base"
    execute "CREATE VIEW vw_domestic_base AS #{sql}"

    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_search"
    execute "CREATE MATERIALIZED VIEW mvw_domestic_search AS
    #{sql} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_domestic_yesterday"
    execute "CREATE VIEW vw_domestic_yesterday AS
    #{sql} AND s.created_at::date = (CURRENT_DATE - 1) OR EXISTS(SELECT * FROM audit_logs l WHERE s.assessment_id=l.assessment_id AND event_type = 'address_id_updated' AND timestamp::date = (CURRENT_DATE - 1))"
  end

  def self.down; end
end
