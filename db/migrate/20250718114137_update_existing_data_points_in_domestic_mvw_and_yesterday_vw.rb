class UpdateExistingDataPointsInDomesticMvwAndYesterdayVw < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_search CASCADE"
    execute "CREATE MATERIALIZED VIEW mvw_domestic_search
    AS
    SELECT
      ad.assessment_id as rrn,
      get_attribute_value('address_line_1', ad.assessment_id) as address1,
      get_attribute_value('address_line_2', ad.assessment_id) as address2,
      get_attribute_value('address_line_3', ad.assessment_id) as address3,
      get_attribute_value('postcode', ad.assessment_id)::varchar as postcode,
      get_attribute_value('inspection_date', ad.assessment_id) as inspection_date,
      get_attribute_value('uprn', ad.assessment_id) as building_reference_number,
      get_attribute_value('environmental_impact_potential', ad.assessment_id) as environment_impact_potential,
      get_attribute_value('energy_consumption_current', ad.assessment_id) as energy_consumption_current,
      get_attribute_value('energy_consumption_potential', ad.assessment_id) as energy_consumption_potential,
      get_attribute_value('environmental_impact_current', ad.assessment_id) as environment_impact_current,
      get_attribute_value('co2_emissions_current', ad.assessment_id) as co2_emissions_current,
      get_attribute_value('co2_emissions_current_per_floor_area', ad.assessment_id) as co2_emiss_curr_per_floor_area,
      get_attribute_value('co2_emissions_potential', ad.assessment_id) as co2_emissions_potential,
      get_attribute_value('total_floor_area', ad.assessment_id) as total_floor_area,
      get_attribute_value('registration_date', ad.assessment_id) as lodgement_date,
      get_attribute_value('report_type', ad.assessment_id) as report_type,
      get_attribute_value('post_town', ad.assessment_id) as posttown,
      get_attribute_value('created_at', ad.assessment_id) as lodgement_datetime,
      get_attribute_value('energy_rating_current', ad.assessment_id) as current_energy_efficiency,
      energy_band_calculator(get_attribute_value('energy_rating_current', ad.assessment_id)::INTEGER, ad.document ->> 'assessment_type') as current_energy_rating,
      get_attribute_value('energy_rating_potential', ad.assessment_id) as potential_energy_efficiency,
      energy_band_calculator(get_attribute_value('energy_rating_potential', ad.assessment_id)::INTEGER, ad.document ->> 'assessment_type') as potential_energy_rating,
      get_attribute_value('extensions_count', ad.assessment_id) as extension_count,
      COALESCE(get_attribute_value('open_fireplaces_count', ad.assessment_id), get_attribute_json('sap_ventilation', ad.assessment_id) ->> 'open_chimneys_count') as number_open_fireplaces,
      get_attribute_value('heated_room_count', ad.assessment_id) as number_heated_rooms,
      get_attribute_value('habitable_room_count', ad.assessment_id) as number_habitable_rooms,

      COALESCE(
        get_attribute_value('low_energy_lighting', ad.assessment_id)::text,
        (SELECT ROUND(SUM(
                    CASE
                      WHEN (sl ->> 'lighting_efficacy')::float > 65 THEN (sl ->> 'lighting_outlets')::integer
                      ELSE NULL
                    END
                  )/NULLIF(SUM((sl ->> 'lighting_outlets')::float), 0) * 100)::text
           FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl
        )
      ) as low_energy_lighting,

      COALESCE(
        get_attribute_value('low_energy_fixed_lighting_outlets_count', ad.assessment_id)::text,
        (SELECT (SUM(
                    CASE
                      WHEN (sl ->> 'lighting_efficacy')::float > 65 THEN (sl ->> 'lighting_outlets')::integer
                      ELSE NULL
                    END
                  ))::text
           FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl
        )
      ) as low_energy_fixed_lighting_outlets_count,

      get_attribute_value('solar_water_heating', ad.assessment_id) as solar_water_heating_flag,

      get_lookup_value('mechanical_ventilation', get_attribute_value('mechanical_ventilation', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mechanical_ventilation,
      get_lookup_value('tenure', get_attribute_value('tenure', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as tenure,
      get_lookup_value('property_type', get_attribute_value('property_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as property_type,
      get_lookup_value('transaction_type', get_attribute_value('transaction_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as transaction_type,
      get_lookup_value('construction_age_band', get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 ->> 'construction_age_band', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as construction_age_band,
      get_lookup_value('built_form', get_attribute_value('built_form', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as built_form,
      CASE
        WHEN t.assessment_type = 'RdSAP'
        THEN get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'meter_type', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id))
        ELSE get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'electricity_tariff', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id))
      END as energy_tariff,
      get_lookup_value('glazed_type', get_attribute_value('multiple_glazing_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as glazed_type,
      get_lookup_value('glazed_area', get_attribute_value('glazed_area', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as glazed_area,
      get_lookup_value('heat_loss_corridor', get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'heat_loss_corridor', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as heat_loss_corridor,
      get_lookup_value('main_fuel', get_attribute_json('sap_heating', ad.assessment_id) -> 'main_heating_details'-> 0 ->> 'main_fuel_type', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as main_fuel,

      get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'unheated_corridor_length' as unheated_corridor_length,
      get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' as floor_level,

      COALESCE(get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'top_storey',
      CASE
        WHEN get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' = '3'
        THEN 'Y'
        ELSE 'N'
      END) as flat_top_storey,

      jsonb_array_length(get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 -> 'sap_floor_dimensions') as flat_storey_count,
      get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'mains_gas' as mains_gas_flag,
      get_attribute_json('sap_energy_source', ad.assessment_id) -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' as photo_supply,

      COALESCE((get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'wind_turbines_count')::integer, jsonb_array_length(get_attribute_json('sap_energy_source', ad.assessment_id) -> 'wind_turbines')) as wind_turbine_count,
      COALESCE(get_attribute_json('lighting_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_current', ad.assessment_id)) as lighting_cost_current,
      COALESCE(get_attribute_json('lighting_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_potential', ad.assessment_id)) as lighting_cost_potential,
      COALESCE(get_attribute_json('heating_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_current', ad.assessment_id)) as heating_cost_current,
      COALESCE(get_attribute_json('heating_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_potential', ad.assessment_id)) as heating_cost_potential,
      COALESCE(get_attribute_json('hot_water_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_current', ad.assessment_id)) as hot_water_cost_current,
      COALESCE(get_attribute_json('hot_water_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_potential', ad.assessment_id)) as hot_water_cost_potential,
      COALESCE(get_attribute_value('multiple_glazed_percentage', ad.assessment_id), get_attribute_value('multiple_glazed_proportion', ad.assessment_id)) as multi_glaze_proportion,

      COALESCE(get_attribute_json('hot_water', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('hot_water', ad.assessment_id) ->> 'description') as hotwater_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as hot_water_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as hot_water_env_eff,

      COALESCE(get_attribute_json('floors', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'description') as floor_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as floor_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as floor_env_eff,

      COALESCE(get_attribute_json('roofs', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'description') as roof_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as roof_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as roof_env_eff,

      COALESCE(get_attribute_json('walls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'description') as walls_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as walls_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as walls_env_eff,

      COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'description', get_attribute_json('windows', ad.assessment_id) ->> 'description') as windows_description,
      get_lookup_value('energy_efficiency_rating', COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'energy_efficiency_rating', get_attribute_json('windows', ad.assessment_id) ->> 'energy_efficiency_rating'), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as windows_energy_eff,
      get_lookup_value('energy_efficiency_rating', COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'environmental_efficiency_rating', get_attribute_json('windows', ad.assessment_id) ->> 'environmental_efficiency_rating'), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as windows_env_eff,

      COALESCE(get_attribute_json('secondary_heating', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'description') as secondheat_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as sheating_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as sheating_env_eff,

      (SELECT COALESCE(STRING_AGG((mh -> 'description' ->> 'value')::text, ', '), STRING_AGG((mh ->> 'description')::text, ', ')) as mainheat_description
      FROM jsonb_array_elements(get_attribute_json('main_heating', ad.assessment_id)) AS mh),

      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheat_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheat_env_eff,

      COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') as mainheatcont_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheatc_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheatc_env_eff,

      COALESCE(get_attribute_json('lighting', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('lighting', ad.assessment_id) ->> 'description') as lighting_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as lighting_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as lighting_env_eff,

      COALESCE(
        get_attribute_value('fixed_lighting_outlets_count', ad.assessment_id),
        (SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::integer, 0))::integer)::text
              FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl)
      ) as fixed_lighting_outlets_count,

      ( SELECT COALESCE(floor_data -> 0 -> 'sap_floor_dimensions' -> 0 -> 'room_height' ->> 'value', floor_data -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'storey_height') as floor_height
        FROM get_attribute_json('sap_building_parts', ad.assessment_id) AS floor_data),

      COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') as main_heating_controls,

      '' as UPRN_SOURCE,
      os_la.name::varchar as LOCAL_AUTHORITY_LABEL,
      os_p.name::varchar as CONSTITUENCY_LABEL,
      os_p.area_code as CONSTITUENCY,
      co.country_name AS COUNTRY,
      ons.region_code as REGION

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
    left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
    WHERE ad.document ->> 'assessment_type' IN ('RdSAP', 'SAP')
      AND co.country_code IN ('EAW', 'ENG', 'WLS')
  WITH NO DATA;"

    add_index :mvw_domestic_search, :rrn, unique: true
    add_index :mvw_domestic_search, :lodgement_date
    add_index :mvw_domestic_search, :local_authority_label
    add_index :mvw_domestic_search, :constituency_label
    add_index :mvw_domestic_search, :current_energy_rating

    execute "DROP VIEW IF EXISTS vw_domestic_yesterday"
    execute "CREATE VIEW vw_domestic_yesterday
    AS
    SELECT
      ad.assessment_id as rrn,
      get_attribute_value('address_line_1', ad.assessment_id) as address1,
      get_attribute_value('address_line_2', ad.assessment_id) as address2,
      get_attribute_value('address_line_3', ad.assessment_id) as address3,
      get_attribute_value('postcode', ad.assessment_id)::varchar as postcode,
      get_attribute_value('inspection_date', ad.assessment_id) as inspection_date,
      get_attribute_value('uprn', ad.assessment_id) as building_reference_number,
      get_attribute_value('environmental_impact_potential', ad.assessment_id) as environment_impact_potential,
      get_attribute_value('energy_consumption_current', ad.assessment_id) as energy_consumption_current,
      get_attribute_value('energy_consumption_potential', ad.assessment_id) as energy_consumption_potential,
      get_attribute_value('environmental_impact_current', ad.assessment_id) as environment_impact_current,
      get_attribute_value('co2_emissions_current', ad.assessment_id) as co2_emissions_current,
      get_attribute_value('co2_emissions_current_per_floor_area', ad.assessment_id) as co2_emiss_curr_per_floor_area,
      get_attribute_value('co2_emissions_potential', ad.assessment_id) as co2_emissions_potential,
      get_attribute_value('total_floor_area', ad.assessment_id) as total_floor_area,
      get_attribute_value('registration_date', ad.assessment_id) as lodgement_date,
      get_attribute_value('report_type', ad.assessment_id) as report_type,
      get_attribute_value('post_town', ad.assessment_id) as posttown,
      get_attribute_value('created_at', ad.assessment_id) as lodgement_datetime,
      get_attribute_value('energy_rating_current', ad.assessment_id) as current_energy_efficiency,
      energy_band_calculator(get_attribute_value('energy_rating_current', ad.assessment_id)::INTEGER, ad.document ->> 'assessment_type') as current_energy_rating,
      get_attribute_value('energy_rating_potential', ad.assessment_id) as potential_energy_efficiency,
      energy_band_calculator(get_attribute_value('energy_rating_potential', ad.assessment_id)::INTEGER, ad.document ->> 'assessment_type') as potential_energy_rating,
      get_attribute_value('extensions_count', ad.assessment_id) as extension_count,
      COALESCE(get_attribute_value('open_fireplaces_count', ad.assessment_id), get_attribute_json('sap_ventilation', ad.assessment_id) ->> 'open_chimneys_count') as number_open_fireplaces,
      get_attribute_value('heated_room_count', ad.assessment_id) as number_heated_rooms,
      get_attribute_value('habitable_room_count', ad.assessment_id) as number_habitable_rooms,

      COALESCE(
        get_attribute_value('low_energy_lighting', ad.assessment_id)::text,
        (SELECT ROUND(SUM(
                    CASE
                      WHEN (sl ->> 'lighting_efficacy')::float > 65 THEN (sl ->> 'lighting_outlets')::integer
                      ELSE NULL
                    END
                  )/NULLIF(SUM((sl ->> 'lighting_outlets')::float), 0) * 100)::text
           FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl
        )
      ) as low_energy_lighting,

      COALESCE(
        get_attribute_value('low_energy_fixed_lighting_outlets_count', ad.assessment_id)::text,
        (SELECT (SUM(
                    CASE
                      WHEN (sl ->> 'lighting_efficacy')::float > 65 THEN (sl ->> 'lighting_outlets')::integer
                      ELSE NULL
                    END
                  ))::text
           FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl
        )
      ) as low_energy_fixed_lighting_outlets_count,

      get_attribute_value('solar_water_heating', ad.assessment_id) as solar_water_heating_flag,

      get_lookup_value('mechanical_ventilation', get_attribute_value('mechanical_ventilation', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mechanical_ventilation,
      get_lookup_value('tenure', get_attribute_value('tenure', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as tenure,
      get_lookup_value('property_type', get_attribute_value('property_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as property_type,
      get_lookup_value('transaction_type', get_attribute_value('transaction_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as transaction_type,
      get_lookup_value('construction_age_band', get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 ->> 'construction_age_band', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as construction_age_band,
      get_lookup_value('built_form', get_attribute_value('built_form', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as built_form,
      CASE
        WHEN t.assessment_type = 'RdSAP'
        THEN get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'meter_type', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id))
        ELSE get_lookup_value('energy_tariff', get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'electricity_tariff', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id))
      END as energy_tariff,
      get_lookup_value('glazed_type', get_attribute_value('multiple_glazing_type', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as glazed_type,
      get_lookup_value('glazed_area', get_attribute_value('glazed_area', ad.assessment_id), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as glazed_area,
      get_lookup_value('heat_loss_corridor', get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'heat_loss_corridor', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as heat_loss_corridor,
      get_lookup_value('main_fuel', get_attribute_json('sap_heating', ad.assessment_id) -> 'main_heating_details'-> 0 ->> 'main_fuel_type', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as main_fuel,

      get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'unheated_corridor_length' as unheated_corridor_length,
      get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' as floor_level,

      COALESCE(get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'top_storey',
      CASE
        WHEN get_attribute_json('sap_flat_details', ad.assessment_id) ->> 'level' = '3'
        THEN 'Y'
        ELSE 'N'
      END) as flat_top_storey,

      jsonb_array_length(get_attribute_json('sap_building_parts', ad.assessment_id) -> 0 -> 'sap_floor_dimensions') as flat_storey_count,
      get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'mains_gas' as mains_gas_flag,
      get_attribute_json('sap_energy_source', ad.assessment_id) -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' as photo_supply,

      COALESCE((get_attribute_json('sap_energy_source', ad.assessment_id) ->> 'wind_turbines_count')::integer, jsonb_array_length(get_attribute_json('sap_energy_source', ad.assessment_id) -> 'wind_turbines')) as wind_turbine_count,
      COALESCE(get_attribute_json('lighting_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_current', ad.assessment_id)) as lighting_cost_current,
      COALESCE(get_attribute_json('lighting_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('lighting_cost_potential', ad.assessment_id)) as lighting_cost_potential,
      COALESCE(get_attribute_json('heating_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_current', ad.assessment_id)) as heating_cost_current,
      COALESCE(get_attribute_json('heating_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('heating_cost_potential', ad.assessment_id)) as heating_cost_potential,
      COALESCE(get_attribute_json('hot_water_cost_current', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_current', ad.assessment_id)) as hot_water_cost_current,
      COALESCE(get_attribute_json('hot_water_cost_potential', ad.assessment_id) ->> 'value', get_attribute_value('hot_water_cost_potential', ad.assessment_id)) as hot_water_cost_potential,
      COALESCE(get_attribute_value('multiple_glazed_percentage', ad.assessment_id), get_attribute_value('multiple_glazed_proportion', ad.assessment_id)) as multi_glaze_proportion,

      COALESCE(get_attribute_json('hot_water', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('hot_water', ad.assessment_id) ->> 'description') as hotwater_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as hot_water_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('hot_water', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as hot_water_env_eff,

      COALESCE(get_attribute_json('floors', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'description') as floor_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as floor_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('floors', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as floor_env_eff,

      COALESCE(get_attribute_json('roofs', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'description') as roof_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as roof_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('roofs', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as roof_env_eff,

      COALESCE(get_attribute_json('walls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'description') as walls_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as walls_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('walls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as walls_env_eff,

      COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'description', get_attribute_json('windows', ad.assessment_id) ->> 'description') as windows_description,
      get_lookup_value('energy_efficiency_rating', COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'energy_efficiency_rating', get_attribute_json('windows', ad.assessment_id) ->> 'energy_efficiency_rating'), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as windows_energy_eff,
      get_lookup_value('energy_efficiency_rating', COALESCE(get_attribute_json('window', ad.assessment_id) ->> 'environmental_efficiency_rating', get_attribute_json('windows', ad.assessment_id) ->> 'environmental_efficiency_rating'), t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as windows_env_eff,

      COALESCE(get_attribute_json('secondary_heating', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'description') as secondheat_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as sheating_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('secondary_heating', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as sheating_env_eff,

      (SELECT COALESCE(STRING_AGG((mh -> 'description' ->> 'value')::text, ', '), STRING_AGG((mh ->> 'description')::text, ', ')) as mainheat_description
      FROM jsonb_array_elements(get_attribute_json('main_heating', ad.assessment_id)) AS mh),

      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheat_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheat_env_eff,

      COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') as mainheatcont_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheatc_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as mainheatc_env_eff,

      COALESCE(get_attribute_json('lighting', ad.assessment_id) -> 'description' ->> 'value', get_attribute_json('lighting', ad.assessment_id) ->> 'description') as lighting_description,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'energy_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as lighting_energy_eff,
      get_lookup_value('energy_efficiency_rating', get_attribute_json('lighting', ad.assessment_id) ->> 'environmental_efficiency_rating', t.assessment_type, get_attribute_value('schema_type', ad.assessment_id)) as lighting_env_eff,

      COALESCE(
        get_attribute_value('fixed_lighting_outlets_count', ad.assessment_id),
        (SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::integer, 0))::integer)::text
              FROM jsonb_array_elements(get_attribute_json('sap_lighting', ad.assessment_id) -> 0) AS sl)
      ) as fixed_lighting_outlets_count,

      ( SELECT COALESCE(floor_data -> 0 -> 'sap_floor_dimensions' -> 0 -> 'room_height' ->> 'value', floor_data -> 0 -> 'sap_floor_dimensions' -> 0 ->> 'storey_height') as floor_height
        FROM get_attribute_json('sap_building_parts', ad.assessment_id) AS floor_data),

      COALESCE(get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 -> 'description' ->> 'value', get_attribute_json('main_heating_controls', ad.assessment_id) -> 0 ->> 'description') as main_heating_controls,

      '' as UPRN_SOURCE,
      os_la.name::varchar as LOCAL_AUTHORITY_LABEL,
      os_p.name::varchar as CONSTITUENCY_LABEL,
      os_p.area_code as CONSTITUENCY,
      co.country_name AS COUNTRY,
      ons.region_code as REGION

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
      left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
      WHERE ad.document ->> 'assessment_type' IN ('RdSAP', 'SAP')
        AND co.country_code IN ('EAW', 'ENG', 'WLS')
        AND warehouse_created_at::date = CURRENT_DATE - 1;"
  end

  def self.down; end
end
