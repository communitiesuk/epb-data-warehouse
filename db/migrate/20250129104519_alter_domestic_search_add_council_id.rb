class AlterDomesticSearchAddCouncilId < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_search"
    execute "CREATE MATERIALIZED VIEW mvw_domestic_search
AS
    SELECT
    ad.assessment_id as RRN,
    document ->> 'address_line_1' as ADDRESS1,
    document ->> 'address_line_2' as ADDRESS2,
    document ->> 'address_line_3' as ADDRESS3,
    document ->> 'postcode' as POSTCODE,
    document ->> 'inspection_date' AS INSPECTION_DATE,
    document ->> 'environmental_impact_potential' AS ENVIRONMENT_IMPACT_POTENTIAL,
    document ->> 'energy_consumption_current' AS ENERGY_CONSUMPTION_CURRENT,
    document ->> 'energy_consumption_potential' AS ENERGY_CONSUMPTION_POTENTIAL,
    document ->> 'environmental_impact_current' AS ENVIRONMENT_IMPACT_CURRENT,
    document ->> 'co2_emissions_current' AS CO2_EMISSIONS_CURRENT,
    document ->> 'co2_emissions_current_per_floor_area' AS CO2_EMISS_CURR_PER_FLOOR_AREA,
    document ->> 'co2_emissions_potential' AS CO2_EMISSIONS_POTENTIAL,
    document -> 'hot_water' ->> 'description' as HOTWATER_DESCRIPTION,
    document -> 'hot_water' ->> 'energy_efficiency_rating' as HOT_WATER_ENERGY_EFF,
    document -> 'hot_water' ->> 'environmental_efficiency_rating' AS HOT_WATER_ENV_EFF,
    document -> 'floors' -> 0 ->> 'description' as FLOOR_DESCRIPTION,
    document -> 'floors' -> 0 ->> 'energy_efficiency_rating' as FLOOR_ENERGY_EFF,
    document -> 'floors' -> 0 ->> 'environmental_efficiency_rating' as FLOOR_ENV_EFF,
    document -> 'secondary_heating' ->> 'description' as SECONDHEAT_DESCRIPTION,
    document -> 'secondary_heating' ->> 'energy_efficiency_rating' as SHEATING_ENERGY_EFF,
    document -> 'secondary_heating' ->> 'environmental_efficiency_rating' as SHEATING_ENV_EFF,
    document -> 'roofs' -> 0 ->> 'description' as ROOF_DESCRIPTION,
    document -> 'roofs' -> 0 ->> 'energy_efficiency_rating' as ROOF_ENERGY_EFF,
    document -> 'roofs' -> 0 ->> 'environmental_efficiency_rating' as ROOF_ENV_EFF,
    document -> 'main_heating' -> 0 ->> 'description' as MAINHEAT_DESCRIPTION,
    document -> 'main_heating' -> 0 ->> 'energy_efficiency_rating' as MAINHEAT_ENERGY_EFF,
    document -> 'main_heating' -> 0 ->> 'environmental_efficiency_rating' as MAINHEAT_ENV_EFF,
    document -> 'main_heating_controls' -> 0 ->> 'description' as MAINHEATCONT_DESCRIPTION,
    document -> 'main_heating_controls' -> 0 ->> 'energy_efficiency_rating' as MAINHEATC_ENERGY_EFF,
    document -> 'main_heating_controls' -> 0 ->> 'environmental_efficiency_rating' as MAINHEATC_ENV_EFF,
    document -> 'lighting' ->> 'description' as LIGHTING_DESCRIPTION,
    document -> 'lighting' ->> 'energy_efficiency_rating' as LIGHTING_ENERGY_EFF,
    document -> 'lighting' ->> 'environmental_efficiency_rating' as LIGHTING_ENV_EFF,
    document ->> 'total_floor_area' as TOTAL_FLOOR_AREA,
    document ->> 'registration_date' as LODGEMENT_DATE,
    document ->> 'report_type' as REPORT_TYPE,
    document ->> 'post_town' as POSTTOWN,
    document ->> 'tenure' as TENURE,
    document ->> 'created_at' as LODGEMENT_DATETIME,
    document ->> 'energy_rating_current' as CURRENT_ENERGY_EFFICIENCY,
    energy_band_calculator((document ->> 'energy_rating_current')::int, document ->> 'assessment_type') as CURRENT_ENERGY_RATING,
    document ->> 'energy_rating_potential' AS POTENTIAL_ENERGY_EFFICIENCY,
    energy_band_calculator((document ->> 'energy_rating_potential')::int, document ->> 'assessment_type') as POTENTIAL_ENERGY_RATING,
    document -> 'sap_data' ->> 'extensions_count' as EXTENSION_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'built_form' ELSE document ->> 'built_form' END AS BUILT_FORM,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'unheated_corridor_length' ELSE document ->> 'unheated_corridor_length' END AS UNHEATED_CORRIDOR_LENGTH,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'open_fireplaces_count' ELSE document ->> 'open_fireplaces_count' END AS NUMBER_OPEN_FIREPLACES,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'heated_room_count' ELSE document ->> 'heated_room_count' END AS NUMBER_HEATED_ROOMS,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'habitable_room_count' ELSE document ->> 'habitable_room_count' END AS NUMBER_HABITABLE_ROOMS,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' ->> 'mains_gas' ELSE document ->> 'mains_gas' END AS MAINS_GAS_FLAG,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' ELSE document -> 'sap_energy_source' -> 'photovoltaic_supply' -> 'none_or_no_details' ->> 'percent_roof_area' END AS PHOTO_SUPPLY,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_energy_source' ->> 'electricity_tariff' ELSE document -> 'sap_energy_source' ->> 'electricity_tariff' END AS ENERGY_TARIFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'low_energy_lighting' ELSE document ->> 'low_energy_lighting' END AS LOW_ENERGY_LIGHTING,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'low_energy_fixed_lighting_outlets_count' ELSE document ->> 'low_energy_fixed_lighting_bulbs_count' END AS LOW_ENERGY_FIXED_LIGHTING_OUTLETS_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'heat_loss_corridor' ELSE document ->> 'heat_loss_corridor' END AS HEAT_LOSS_CORRIDOR,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'glazed_area' ELSE document ->> 'glazed_area' END as GLAZED_AREA,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'multiple_glazing_type' ELSE document ->> 'multiple_glazing_type' END as GLAZED_TYPE,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'level' ELSE document ->> 'level' END AS FLOOR_LEVEL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_flat_details' ->> 'top_storey' ELSE document ->> 'top_storey' END AS FLAT_TOP_STOREY,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN (document -> 'sap_data' -> 'sap_flat_details' ->> 'storey_count')::int ELSE COALESCE(jsonb_array_length(document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions'), 0) END AS FLAT_STOREY_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'description' ELSE document -> 'windows' ->> 'description' END AS WINDOWS_DESCRIPTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'energy_efficiency_rating' ELSE document -> 'windows' ->> 'energy_efficiency_rating' END AS WINDOWS_ENERGY_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'window' ->> 'environmental_efficiency_rating' ELSE document -> 'windows' ->> 'environmental_efficiency_rating' END AS WINDOWS_ENV_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' ELSE document -> 'sap_heating' -> 'main_heating_details' -> 0 ->> 'main_fuel_type' END MAIN_FUEL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN (document -> 'sap_data' -> 'sap_energy_source' ->> 'wind_turbines_count')::int ELSE COALESCE(jsonb_array_length(document -> 'sap_energy_source' -> 'wind_turbines'), 0)  END AS WIND_TURBINE_COUNT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'environmental_efficiency_rating' ELSE document -> 'walls' -> 0 ->> 'environmental_efficiency_rating' END AS WALLS_ENV_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'description' ELSE document -> 'walls' -> 0 ->> 'description' END AS WALLS_DESCRIPTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'wall' ->> 'energy_efficiency_rating' ELSE document -> 'walls' -> 0 ->> 'energy_efficiency_rating' END AS WALLS_ENERGY_EFF,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'lighting_cost_current' ELSE document -> 'lighting_cost_current' ->> 'value' END AS LIGHTING_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'lighting_cost_potential' ELSE document -> 'lighting_cost_potential' ->> 'value' END AS LIGHTING_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'heating_cost_current' ELSE document -> 'heating_cost_current' ->> 'value' END AS HEATING_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'heating_cost_potential' ELSE document -> 'heating_cost_potential' ->> 'value' END AS HEATING_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'hot_water_cost_current' ELSE document -> 'hot_water_cost_current' ->> 'value' END AS HOT_WATER_COST_CURRENT,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document ->> 'hot_water_cost_potential' ELSE document -> 'hot_water_cost_potential' ->> 'value' END AS HOT_WATER_COST_POTENTIAL,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'multiple_glazed_proportion' ELSE document ->> 'multiple_glazed_percentage' END AS MULTI_GLAZE_PROPORTION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'solar_water_heating' ELSE document ->> 'solar_water_heating' END AS SOLAR_WATER_HEATING_FLAG,
    CASE WHEN document ->> 'uprn' LIKE 'UPRN-%' THEN document ->> 'uprn' ELSE '' END as BUILDING_REFERENCE_NUMBER,
 CASE WHEN document ->> 'assessment_type' = 'RdSAP' THEN document -> 'sap_data' ->> 'mechanical_ventilation' ELSE document -> 'sap_ventilation' ->> 'mechanical_ventilation_data_source' END AS MECHANICAL_VENTILATION,
    CASE WHEN document ->> 'assessment_type' = 'RdSAP'
      THEN (
          SELECT ROUND(AVG((sfd -> 'room_height' ->> 'value')::numeric), 2)::varchar
          FROM jsonb_array_elements((document -> 'sap_data' -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions')) AS sfd
      )
      ELSE (
          SELECT ROUND(AVG((sfd ->> 'storey_height')::numeric), 2)::varchar
          FROM jsonb_array_elements((document -> 'sap_building_parts' -> 0 -> 'sap_floor_dimensions')) AS sfd
      )
    END AS FLOOR_HEIGHT,

    CASE WHEN document ->> 'assessment_type' = 'RdSAP'
      THEN ((document -> 'sap_data' ->> 'fixed_lighting_outlets_count')::integer)
    ELSE (
      SELECT (SUM(COALESCE((sl ->> 'lighting_outlets')::integer, 0))::integer)
      FROM jsonb_array_elements((document -> 'sap_lighting' -> 0)) AS sl
    )
    END AS FIXED_LIGHTING_OUTLETS_COUNT,

    '' as UPRN_SOURCE,
    os_la.name as LOCAL_AUTHORITY_LABEL,
    os_p.name as CONSTITUENCY_LABEL,
    os_p.area_code as CONSTITUENCY,
    co.country_name AS COUNTRY,
    ons.region_code as REGION,
   CASE WHEN document ->> 'assessment_type' = 'RdSAP'
    THEN get_lookup_value('construction_age_band', (document -> 'sap_data' -> 'sap_building_parts'-> 0 ->> 'construction_age_band'), document ->> 'assessment_type', document->> 'schema_type' )
    ELSE
      get_lookup_value('construction_age_band', (document -> 'sap_building_parts'-> 0 ->> 'construction_age_band'), document ->> 'assessment_type', document->> 'schema_type' )
 END as CONSTRUCTION_AGE_BAND,

    get_lookup_value('transaction_type', document ->> 'transaction_type', document ->> 'assessment_type', document->> 'schema_type' ) as TRANSACTION_TYPE,
    get_lookup_value('property_type', document ->> 'property_type', document ->> 'assessment_type', document->> 'schema_type' ) as PROPERTY_TYPE,

    (
      SELECT STRING_AGG(mhc ->> 'description', '. ')
      FROM jsonb_array_elements(document -> 'main_heating_controls') AS mhc
    ) AS MAIN_HEATING_CONTROLS,
os_la.id::integer AS COUNCIL_ID


FROM assessment_documents ad
join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
join countries co on aci.country_id = co.country_id
left JOIN ons_postcode_directory ons on document ->> 'postcode' = ons.postcode
left join ons_postcode_directory_names os_la on ons.local_authority_code = os_la.area_code
left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
WHERE document ->> 'assessment_type' IN ('RdSAP', 'SAP')
  AND co.country_code IN ('EAW', 'ENG', 'WLS')
WITH NO DATA;"

    add_index :mvw_domestic_search, :rrn, unique: true
    add_index :mvw_domestic_search, :lodgement_date
    add_index :mvw_domestic_search, :council_id
  end

  def self.down; end
end
