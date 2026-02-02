class UpdateDomesticViewRemoveSapFilter < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
      SELECT
        ad.assessment_id AS CERTIFICATE_NUMBER,
        s.address_line_1 AS ADDRESS1,
        s.address_line_2 AS ADDRESS2,
        s.address_line_3 AS ADDRESS3,
        CONCAT_WS(', ', s.address_line_1, s.address_line_2, s.address_line_3) AS ADDRESS,
        s.postcode AS POSTCODE,
        get_attribute_value('inspection_date', ad.assessment_id) AS INSPECTION_DATE,
        s.uprn,
        get_attribute_value('environmental_impact_potential', ad.assessment_id) AS ENVIRONMENT_IMPACT_POTENTIAL,
        get_attribute_value('energy_consumption_current', ad.assessment_id) AS ENERGY_CONSUMPTION_CURRENT,
        get_attribute_value('energy_consumption_potential', ad.assessment_id) AS ENERGY_CONSUMPTION_POTENTIAL,
        get_attribute_value('environmental_impact_current', ad.assessment_id) AS ENVIRONMENT_IMPACT_CURRENT,
        get_attribute_value('co2_emissions_current', ad.assessment_id) AS CO2_EMISSIONS_CURRENT,
        get_attribute_value('co2_emissions_current_per_floor_area', ad.assessment_id) AS CO2_EMISS_CURR_PER_FLOOR_AREA,
        get_attribute_value('co2_emissions_potential', ad.assessment_id) AS CO2_EMISSIONS_POTENTIAL,
        get_attribute_value('total_floor_area', ad.assessment_id) AS TOTAL_FLOOR_AREA,
        s.registration_date AS LODGEMENT_DATE,
        get_attribute_value('report_type', ad.assessment_id) AS REPORT_TYPE,
        s.post_town AS POSTTOWN,
        s.created_at AS LODGEMENT_DATETIME,
        s.current_energy_efficiency_rating::VARCHAR AS CURRENT_ENERGY_EFFICIENCY,
        s.current_energy_efficiency_band AS CURRENT_ENERGY_RATING,
        get_attribute_value('energy_rating_potential', ad.assessment_id) AS POTENTIAL_ENERGY_EFFICIENCY,
        energy_band_calculator(get_attribute_value('energy_rating_potential', ad.assessment_id)::INTEGER, ad.document ->> 'assessment_type') AS POTENTIAL_ENERGY_RATING,
        get_attribute_value('extensions_count', ad.assessment_id) AS EXTENSION_COUNT,
        COALESCE(
            get_attribute_value('open_fireplaces_count', ad.assessment_id),
            get_attribute_value('open_chimneys_count', ad.assessment_id),
            get_attribute_json('sap_ventilation', ad.assessment_id) ->> 'open_chimneys_count',
            get_attribute_json('sap_ventilation', ad.assessment_id) ->> 'open_fireplaces_count'
        ) AS NUMBER_OPEN_FIREPLACES,
        get_attribute_value('heated_room_count', ad.assessment_id) AS NUMBER_HEATED_ROOMS,
        get_attribute_value('habitable_room_count', ad.assessment_id) AS NUMBER_HABITABLE_ROOMS,
      #{'         '}
        COALESCE(
            get_attribute_value('low_energy_lighting', ad.assessment_id)::TEXT,
            get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'low_energy_fixed_lighting_outlets_percentage',
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
                  jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl
            )
        ) AS LOW_ENERGY_LIGHTING,
      #{'         '}
        COALESCE(
          get_attribute_value('low_energy_fixed_lighting_outlets_count', ad.assessment_id)::TEXT,
          get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'low_energy_fixed_lighting_outlets_count',
          (
            sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count'], ad.assessment_id)
          )::TEXT,
          (SELECT (SUM(
                      CASE
                        WHEN (sl ->> 'lighting_efficacy')::FLOAT > 65 THEN (sl ->> 'lighting_outlets')::INTEGER
                        ELSE NULL
                      END
                    ))::TEXT
             FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0 ) AS sl
          )
        ) AS LOW_ENERGY_FIXED_LIGHTING_OUTLETS_COUNT,
      #{'         '}
        get_attribute_value('solar_water_heating', ad.assessment_id) AS SOLAR_WATER_HEATING_FLAG,
        get_lookup_value('mechanical_ventilation', get_attribute_value('mechanical_ventilation', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MECHANICAL_VENTILATION,
        get_lookup_value('tenure', get_attribute_value('tenure', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS TENURE,
        get_lookup_value('property_type', get_attribute_value('property_type', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS PROPERTY_TYPE,
        get_lookup_value('transaction_type', get_attribute_value('transaction_type', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS TRANSACTION_TYPE,
        COALESCE(
          get_lookup_value('construction_age_band', get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 ->> 'construction_age_band', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)),
          get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 ->> 'construction_age_band',
          get_attribute_json('sap_building_parts', ad.assessment_id) -> 1 ->> 'construction_age_band'
        ) AS CONSTRUCTION_AGE_BAND,
        get_lookup_value('built_form', get_attribute_value('built_form', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS BUILT_FORM,
      #{'  '}
        CASE
          WHEN ad.document ->> 'assessment_type' = 'RdSAP'
          THEN get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'meter_type', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id))
          ELSE get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'electricity_tariff', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id))
        END AS ENERGY_TARIFF,
      #{'      '}
        get_lookup_value('glazed_type', get_attribute_value('multiple_glazing_type', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS GLAZED_TYPE,
        get_lookup_value('glazed_area', get_attribute_value('glazed_area', ad.assessment_id), ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS GLAZED_AREA,
        get_lookup_value('heat_loss_corridor', get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'heat_loss_corridor', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS HEAT_LOSS_CORRIDOR,
        get_lookup_value('main_fuel', get_attribute_json('sap_heating', ad.assessment_id) -> 'main_heating_details'-> 0 ->> 'main_fuel_type', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MAIN_FUEL,
        get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'unheated_corridor_length' AS UNHEATED_CORRIDOR_LENGTH,
        get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' AS FLOOR_LEVEL,
      #{'      '}
        COALESCE(get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'top_storey',
        CASE
          WHEN get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' = '3'
          THEN 'Y'
          ELSE 'N'
        END) AS FLAT_TOP_STOREY,
      #{'      '}
        jsonb_array_length(get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 -> 'sap_floor_dimensions') AS FLAT_STOREY_COUNT,
        get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'mains_gas' AS MAINS_GAS_FLAG,
        get_attribute_json('sap_energy_source', ad.assessment_id) -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' AS PHOTO_SUPPLY,
      #{'  '}
        COALESCE((get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'wind_turbines_count')::INTEGER, jsonb_array_length(get_attribute_json('sap_energy_source', ad.assessment_id) -> 'wind_turbines')) AS WIND_TURBINE_COUNT,
        COALESCE(get_attribute_json('lighting_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_current', ad.assessment_id)) AS LIGHTING_COST_CURRENT,
        COALESCE(get_attribute_json('lighting_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_potential', ad.assessment_id)) AS LIGHTING_COST_POTENTIAL,
        COALESCE(get_attribute_json('heating_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_current', ad.assessment_id)) AS HEATING_COST_CURRENT,
        COALESCE(get_attribute_json('heating_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_potential', ad.assessment_id)) AS HEATING_COST_POTENTIAL,
        COALESCE(get_attribute_json('hot_water_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_current', ad.assessment_id)) AS HOT_WATER_COST_CURRENT,
        COALESCE(get_attribute_json('hot_water_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_potential', ad.assessment_id)) AS HOT_WATER_COST_POTENTIAL,
        COALESCE(get_attribute_value('multiple_glazed_percentage', ad.assessment_id), get_attribute_value('multiple_glazed_proportion', ad.assessment_id)) AS MULTI_GLAZE_PROPORTION,
      #{'  '}
        COALESCE(get_attribute_json('hot_water', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('hot_water', ad.assessment_id) ->> 'description') AS HOTWATER_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS HOT_WATER_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS HOT_WATER_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('floors', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'description') AS FLOOR_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS FLOOR_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS FLOOR_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('roofs', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'description') AS ROOF_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS ROOF_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS ROOF_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('walls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'description') AS WALLS_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS WALLS_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS WALLS_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'description', get_attribute_json('window', ad.assessment_id) -> 0 ->> 'description', get_attribute_json('windows', ad.assessment_id) ->> 'description', get_attribute_json('windows', ad.assessment_id) -> 0 ->> 'description') AS WINDOWS_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', COALESCE(
                                                      get_attribute_json('window', ad.assessment_id) ->> 'energy_efficiency_rating',
                                                      get_attribute_json('window', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating',
                                                      get_attribute_json('windows', ad.assessment_id) ->> 'energy_efficiency_rating',
                                                      get_attribute_json('windows', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating'
                                                    ),
          ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS WINDOWS_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', COALESCE(
                                                      get_attribute_json('window', ad.assessment_id) ->> 'environmental_efficiency_rating',
                                                      get_attribute_json('windows', ad.assessment_id) ->> 'environmental_efficiency_rating',
                                                      get_attribute_json('window', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating',
                                                      get_attribute_json('windows', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating'
                                                    ),
          ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS WINDOWS_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('secondary_heating', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'description') AS SECONDHEAT_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS SHEATING_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS SHEATING_ENV_EFF,
      #{'  '}
        (SELECT COALESCE(STRING_AGG((mh -> 'description' ->> 'value')::TEXT, ', '), STRING_AGG((mh ->> 'description')::TEXT, ', ')) AS MAINHEAT_DESCRIPTION
        FROM jsonb_array_elements(get_attribute_json('main_heating', ad.assessment_id)) AS mh),
        get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MAINHEAT_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MAINHEAT_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') AS MAINHEATCONT_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MAINHEATC_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS MAINHEATC_ENV_EFF,
      #{'  '}
        COALESCE(get_attribute_json('lighting', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('lighting', ad.assessment_id) ->> 'description') AS LIGHTING_DESCRIPTION,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'energy_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS LIGHTING_ENERGY_EFF,
        get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'environmental_efficiency_rating', ad.document ->> 'assessment_type', get_attribute_value('schema_type', ad.assessment_id)) AS LIGHTING_ENV_EFF,
      #{'  '}
        COALESCE(
          get_attribute_value('fixed_lighting_outlets_count', ad.assessment_id),
          get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'fixed_lighting_outlets_count',
          (
            sum_attribute_values(ARRAY['cfl_fixed_lighting_bulbs_count', 'led_fixed_lighting_bulbs_count', 'low_energy_fixed_lighting_bulbs_count', 'incandescent_fixed_lighting_bulbs_count'], ad.assessment_id)
          )::TEXT,
          (SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::INTEGER, 0))::INTEGER)::TEXT
                FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl)
        ) AS FIXED_LIGHTING_OUTLETS_COUNT,
        ( SELECT COALESCE(floor_data -> 0 -> 'sap_floor_dimensions' -> 0 -> 'room_height' ->> 'value', floor_data -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'storey_height', floor_data -> 0 ->> 'room_height', floor_data -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'room_height') AS floor_height
          FROM get_attribute_json('sap_building_parts', ad.assessment_id) AS floor_data),
        COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') AS MAIN_HEATING_CONTROLS,
        ons.local_authority_code AS LOCAL_AUTHORITY,
        s.council AS LOCAL_AUTHORITY_LABEL,
        s.constituency AS CONSTITUENCY_LABEL,
        os_p.area_code AS CONSTITUENCY,
        co.country_name AS COUNTRY,
        ons.region_code AS REGION
      FROM assessment_documents AS ad
      JOIN assessment_search AS s ON s.assessment_id = ad.assessment_id
      JOIN ( VALUES ('SAP'), ('RdSAP') ) AS vals (t) ON (assessment_type = t)
      JOIN assessments_country_ids AS aci ON ad.assessment_id = aci.assessment_id
      JOIN countries AS co ON aci.country_id = co.country_id
      LEFT JOIN ons_postcode_directory AS ons ON s.postcode = ons.postcode
      LEFT JOIN ons_postcode_directory_names AS os_p ON ons.westminster_parliamentary_constituency_code = os_p.area_code
    SQL
  end

  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_search"
    execute "CREATE MATERIALIZED VIEW mvw_domestic_search AS
    #{sql} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_domestic_yesterday"
    execute "CREATE VIEW vw_domestic_yesterday AS
    #{sql} WHERE s.created_at::date = (CURRENT_DATE - 1) OR updated_at::date = (CURRENT_DATE - 1)"
  end

  def self.down; end
end
