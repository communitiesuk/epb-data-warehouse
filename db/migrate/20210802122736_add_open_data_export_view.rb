class AddOpenDataExportView < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
           create view vw_open_data_export
                  (assessment_id, address1, address2, address3, building_reference_number, built_form,
                   co2_emiss_curr_per_floor_area, co2_emissions_current, co2_emissions_potential, construction_age_band,
                   current_energy_efficiency, current_energy_rating, energy_consumption_current, energy_consumption_potential,
                   energy_tariff, environment_impact_current, environment_impact_potential, extension_count,
                   fixed_lighting_outlets_count, flat_storey_count, flat_top_storey, floor_description, floor_energy_eff,
                   floor_env_eff, floor_height, floor_level, glazed_area, glazed_type, heat_loss_corridor,
                   heating_cost_current, heating_cost_potential, hot_water_cost_current, hot_water_cost_potential,
                   hot_water_energy_eff, hot_water_env_eff, hotwater_description, inspection_date, lighting_cost_current,
                   lighting_cost_potential, lighting_description, lighting_energy_eff, lighting_env_eff, lodgement_date,
                   lodgement_datetime, low_energy_fixed_lighting_outlets_count, low_energy_lighting, main_fuel,
                   mainheat_description, mainheat_energy_eff, mainheat_env_eff, mainheatc_energy_eff, mainheatc_env_eff,
                   mainheatcont_description, mains_gas_flag, mechanical_ventilation, multi_glaze_proportion,
                   number_habitable_rooms, number_heated_rooms, number_open_fireplaces, photo_supply, postcode, posttown,
                   potential_energy_efficiency, potential_energy_rating, property_type, report_type, roof_description,
                   roof_energy_eff, roof_env_eff, secondheat_description, sheating_energy_eff, sheating_env_eff,
                   solar_water_heating_flag, tenure, total_floor_area, transaction_type, unheated_corridor_length,
                   walls_description, walls_energy_eff, walls_env_eff, wind_turbine_count, windows_description,
                   windows_energy_eff, windows_env_eff)
      as
      SELECT virtual_columns.assessment_id,
             virtual_columns.address1,
             virtual_columns.address2,
             virtual_columns.address3,
             virtual_columns.building_reference_number,
             virtual_columns.built_form,
             virtual_columns.co2_emiss_curr_per_floor_area,
             virtual_columns.co2_emissions_current,
             virtual_columns.co2_emissions_potential,
             virtual_columns.construction_age_band,
             virtual_columns.current_energy_efficiency,
             virtual_columns.current_energy_rating,
             virtual_columns.energy_consumption_current,
             virtual_columns.energy_consumption_potential,
             virtual_columns.energy_tariff,
             virtual_columns.environment_impact_current,
             virtual_columns.environment_impact_potential,
             virtual_columns.extension_count,
             virtual_columns.fixed_lighting_outlets_count,
             virtual_columns.flat_storey_count,
             virtual_columns.flat_top_storey,
             virtual_columns.floor_description,
             virtual_columns.floor_energy_eff,
             virtual_columns.floor_env_eff,
             virtual_columns.floor_height,
             virtual_columns.floor_level,
             virtual_columns.glazed_area,
             virtual_columns.glazed_type,
             virtual_columns.heat_loss_corridor,
             virtual_columns.heating_cost_current,
             virtual_columns.heating_cost_potential,
             virtual_columns.hot_water_cost_current,
             virtual_columns.hot_water_cost_potential,
             virtual_columns.hot_water_energy_eff,
             virtual_columns.hot_water_env_eff,
             virtual_columns.hotwater_description,
             virtual_columns.inspection_date,
             virtual_columns.lighting_cost_current,
             virtual_columns.lighting_cost_potential,
             virtual_columns.lighting_description,
             virtual_columns.lighting_energy_eff,
             virtual_columns.lighting_env_eff,
             virtual_columns.lodgement_date,
             virtual_columns.lodgement_datetime,
             virtual_columns.low_energy_fixed_lighting_outlets_count,
             virtual_columns.low_energy_lighting,
             virtual_columns.main_fuel,
             virtual_columns.mainheat_description,
             virtual_columns.mainheat_energy_eff,
             virtual_columns.mainheat_env_eff,
             virtual_columns.mainheatc_energy_eff,
             virtual_columns.mainheatc_env_eff,
             virtual_columns.mainheatcont_description,
             virtual_columns.mains_gas_flag,
             virtual_columns.mechanical_ventilation,
             virtual_columns.multi_glaze_proportion,
             virtual_columns.number_habitable_rooms,
             virtual_columns.number_heated_rooms,
             virtual_columns.number_open_fireplaces,
             virtual_columns.photo_supply,
             virtual_columns.postcode,
             virtual_columns.posttown,
             virtual_columns.potential_energy_efficiency,
             virtual_columns.potential_energy_rating,
             virtual_columns.property_type,
             virtual_columns.report_type,
             virtual_columns.roof_description,
             virtual_columns.roof_energy_eff,
             virtual_columns.roof_env_eff,
             virtual_columns.secondheat_description,
             virtual_columns.sheating_energy_eff,
             virtual_columns.sheating_env_eff,
             virtual_columns.solar_water_heating_flag,
             virtual_columns.tenure,
             virtual_columns.total_floor_area,
             virtual_columns.transaction_type,
             virtual_columns.unheated_corridor_length,
             virtual_columns.walls_description,
             virtual_columns.walls_energy_eff,
             virtual_columns.walls_env_eff,
             virtual_columns.wind_turbine_count,
             virtual_columns.windows_description,
             virtual_columns.windows_energy_eff,
             virtual_columns.windows_env_eff
      FROM crosstab('
                    SELECT  av.assessment_id, a.attribute_name, av.attribute_value
                    FROM assessment_attribute_values av
                    JOIN assessment_attributes a ON av.attribute_id = a.attribute_id
                    JOIN (SELECT  assessment_id FROM assessment_attributes aa
                               JOIN assessment_attribute_values aav on aa.attribute_id = aav.attribute_id
                               WHERE aa.attribute_id = 76 AND aav.attribute_value IN (''RdSAP'', ''SAP'')
                                GROUP BY assessment_id) w ON W.assessment_Id = av.assessment_id
                    WHERE a.attribute_name IN (''address1'',''address2'',''address3'',''building_reference_number'',''built_form'',''co2_emiss_curr_per_floor_area'',''co2_emissions_current'',''co2_emissions_potential'',''construction_age_band'',''current_energy_efficiency'',''current_energy_rating'',''energy_consumption_current'',''energy_consumption_potential'',''energy_tariff'',''environment_impact_current'',''environment_impact_potential'',''extension_count'',''fixed_lighting_outlets_count'',''flat_storey_count'',''flat_top_storey'',''floor_description'',''floor_energy_eff'',''floor_env_eff'',''floor_height'',''floor_level'',''glazed_area'',''glazed_type'',''heat_loss_corridor'',''heating_cost_current'',''heating_cost_potential'',''hot_water_cost_current'',''hot_water_cost_potential'',''hot_water_energy_eff'',''hot_water_env_eff'',''hotwater_description'',''inspection_date'',''lighting_cost_current'',''lighting_cost_potential'',''lighting_description'',''lighting_energy_eff'',''lighting_env_eff'',''lodgement_date'',''lodgement_datetime'',''low_energy_fixed_lighting_outlets_count'',''low_energy_lighting'',''main_fuel'',''mainheat_description'',''mainheat_energy_eff'',''mainheat_env_eff'',''mainheatc_energy_eff'',''mainheatc_env_eff'',''mainheatcont_description'',''mains_gas_flag'',''mechanical_ventilation'',''multi_glaze_proportion'',''number_habitable_rooms'',''number_heated_rooms'',''number_open_fireplaces'',''photo_supply'',''postcode'',''posttown'',''potential_energy_efficiency'',''potential_energy_rating'',''property_type'',''report_type'',''roof_description'',''roof_energy_eff'',''roof_env_eff'',''secondheat_description'',''sheating_energy_eff'',''sheating_env_eff'',''solar_water_heating_flag'',''tenure'',''total_floor_area'',''transaction_type'',''unheated_corridor_length'',''walls_description'',''walls_energy_eff'',''walls_env_eff'',''wind_turbine_count'',''windows_description'',''windows_energy_eff'',''windows_env_eff''
      )
                    ORDER BY assessment_id,
      CASE attribute_name  WHEN ''address1'' THEN 1 WHEN ''address2'' THEN 2 WHEN ''address3'' THEN 3 WHEN ''building_reference_number'' THEN 4 WHEN ''built_form'' THEN 5 WHEN ''co2_emiss_curr_per_floor_area'' THEN 6 WHEN ''co2_emissions_current'' THEN 7 WHEN ''co2_emissions_potential'' THEN 8 WHEN ''construction_age_band'' THEN 9 WHEN ''current_energy_efficiency'' THEN 10 WHEN ''current_energy_rating'' THEN 11 WHEN ''energy_consumption_current'' THEN 12 WHEN ''energy_consumption_potential'' THEN 13 WHEN ''energy_tariff'' THEN 14 WHEN ''environment_impact_current'' THEN 15 WHEN ''environment_impact_potential'' THEN 16 WHEN ''extension_count'' THEN 17 WHEN ''fixed_lighting_outlets_count'' THEN 18 WHEN ''flat_storey_count'' THEN 19 WHEN ''flat_top_storey'' THEN 20 WHEN ''floor_description'' THEN 21 WHEN ''floor_energy_eff'' THEN 22 WHEN ''floor_env_eff'' THEN 23 WHEN ''floor_height'' THEN 24 WHEN ''floor_level'' THEN 25 WHEN ''glazed_area'' THEN 26 WHEN ''glazed_type'' THEN 27 WHEN ''heat_loss_corridor'' THEN 28 WHEN ''heating_cost_current'' THEN 29 WHEN ''heating_cost_potential'' THEN 30 WHEN ''hot_water_cost_current'' THEN 31 WHEN ''hot_water_cost_potential'' THEN 32 WHEN ''hot_water_energy_eff'' THEN 33 WHEN ''hot_water_env_eff'' THEN 34 WHEN ''hotwater_description'' THEN 35 WHEN ''inspection_date'' THEN 36 WHEN ''lighting_cost_current'' THEN 37 WHEN ''lighting_cost_potential'' THEN 38 WHEN ''lighting_description'' THEN 39 WHEN ''lighting_energy_eff'' THEN 40 WHEN ''lighting_env_eff'' THEN 41 WHEN ''lodgement_date'' THEN 42 WHEN ''lodgement_datetime'' THEN 43 WHEN ''low_energy_fixed_lighting_outlets_count'' THEN 44 WHEN ''low_energy_lighting'' THEN 45 WHEN ''main_fuel'' THEN 46 WHEN ''mainheat_description'' THEN 47 WHEN ''mainheat_energy_eff'' THEN 48 WHEN ''mainheat_env_eff'' THEN 49 WHEN ''mainheatc_energy_eff'' THEN 50 WHEN ''mainheatc_env_eff'' THEN 51 WHEN ''mainheatcont_description'' THEN 52 WHEN ''mains_gas_flag'' THEN 53 WHEN ''mechanical_ventilation'' THEN 54 WHEN ''multi_glaze_proportion'' THEN 55 WHEN ''number_habitable_rooms'' THEN 56 WHEN ''number_heated_rooms'' THEN 57 WHEN ''number_open_fireplaces'' THEN 58 WHEN ''photo_supply'' THEN 59 WHEN ''postcode'' THEN 60 WHEN ''posttown'' THEN 61 WHEN ''potential_energy_efficiency'' THEN 62 WHEN ''potential_energy_rating'' THEN 63 WHEN ''property_type'' THEN 64 WHEN ''report_type'' THEN 65 WHEN ''roof_description'' THEN 66 WHEN ''roof_energy_eff'' THEN 67 WHEN ''roof_env_eff'' THEN 68 WHEN ''secondheat_description'' THEN 69 WHEN ''sheating_energy_eff'' THEN 70 WHEN ''sheating_env_eff'' THEN 71 WHEN ''solar_water_heating_flag'' THEN 72 WHEN ''tenure'' THEN 73 WHEN ''total_floor_area'' THEN 74 WHEN ''transaction_type'' THEN 75 WHEN ''unheated_corridor_length'' THEN 76 WHEN ''walls_description'' THEN 77 WHEN ''walls_energy_eff'' THEN 78 WHEN ''walls_env_eff'' THEN 79 WHEN ''wind_turbine_count'' THEN 80 WHEN ''windows_description'' THEN 81 WHEN ''windows_energy_eff'' THEN 82 WHEN ''windows_env_eff'' THEN 83 ELSE 84 END
                    '::text, ' SELECT * FROM ( values (''address1''),(''address2''),(''address3''),(''building_reference_number''),(''built_form''),(''co2_emiss_curr_per_floor_area''),(''co2_emissions_current''),(''co2_emissions_potential''),(''construction_age_band''),(''current_energy_efficiency''),(''current_energy_rating''),(''energy_consumption_current''),(''energy_consumption_potential''),(''energy_tariff''),(''environment_impact_current''),(''environment_impact_potential''),(''extension_count''),(''fixed_lighting_outlets_count''),(''flat_storey_count''),(''flat_top_storey''),(''floor_description''),(''floor_energy_eff''),(''floor_env_eff''),(''floor_height''),(''floor_level''),(''glazed_area''),(''glazed_type''),(''heat_loss_corridor''),(''heating_cost_current''),(''heating_cost_potential''),(''hot_water_cost_current''),(''hot_water_cost_potential''),(''hot_water_energy_eff''),(''hot_water_env_eff''),(''hotwater_description''),(''inspection_date''),(''lighting_cost_current''),(''lighting_cost_potential''),(''lighting_description''),(''lighting_energy_eff''),(''lighting_env_eff''),(''lodgement_date''),(''lodgement_datetime''),(''low_energy_fixed_lighting_outlets_count''),(''low_energy_lighting''),(''main_fuel''),(''mainheat_description''),(''mainheat_energy_eff''),(''mainheat_env_eff''),(''mainheatc_energy_eff''),(''mainheatc_env_eff''),(''mainheatcont_description''),(''mains_gas_flag''),(''mechanical_ventilation''),(''multi_glaze_proportion''),(''number_habitable_rooms''),(''number_heated_rooms''),(''number_open_fireplaces''),(''photo_supply''),(''postcode''),(''posttown''),(''potential_energy_efficiency''),(''potential_energy_rating''),(''property_type''),(''report_type''),(''roof_description''),(''roof_energy_eff''),(''roof_env_eff''),(''secondheat_description''),(''sheating_energy_eff''),(''sheating_env_eff''),(''solar_water_heating_flag''),(''tenure''),(''total_floor_area''),(''transaction_type''),(''unheated_corridor_length''),(''walls_description''),(''walls_energy_eff''),(''walls_env_eff''),(''wind_turbine_count''),(''windows_description''),(''windows_energy_eff''),(''windows_env_eff'')
      ) a '::text) virtual_columns(assessment_id character varying, address1 character varying, address2 character varying,
                                   address3 character varying, building_reference_number character varying,
                                   built_form character varying, co2_emiss_curr_per_floor_area character varying,
                                   co2_emissions_current character varying, co2_emissions_potential character varying,
                                   construction_age_band character varying, current_energy_efficiency character varying,
                                   current_energy_rating character varying, energy_consumption_current character varying,
                                   energy_consumption_potential character varying, energy_tariff character varying,
                                   environment_impact_current character varying,
                                   environment_impact_potential character varying, extension_count character varying,
                                   fixed_lighting_outlets_count character varying, flat_storey_count character varying,
                                   flat_top_storey character varying, floor_description character varying,
                                   floor_energy_eff character varying, floor_env_eff character varying,
                                   floor_height character varying, floor_level character varying,
                                   glazed_area character varying, glazed_type character varying,
                                   heat_loss_corridor character varying, heating_cost_current character varying,
                                   heating_cost_potential character varying, hot_water_cost_current character varying,
                                   hot_water_cost_potential character varying, hot_water_energy_eff character varying,
                                   hot_water_env_eff character varying, hotwater_description character varying,
                                   inspection_date character varying, lighting_cost_current character varying,
                                   lighting_cost_potential character varying, lighting_description character varying,
                                   lighting_energy_eff character varying, lighting_env_eff character varying,
                                   lodgement_date character varying, lodgement_datetime character varying,
                                   low_energy_fixed_lighting_outlets_count character varying,
                                   low_energy_lighting character varying, main_fuel character varying,
                                   mainheat_description character varying, mainheat_energy_eff character varying,
                                   mainheat_env_eff character varying, mainheatc_energy_eff character varying,
                                   mainheatc_env_eff character varying, mainheatcont_description character varying,
                                   mains_gas_flag character varying, mechanical_ventilation character varying,
                                   multi_glaze_proportion character varying, number_habitable_rooms character varying,
                                   number_heated_rooms character varying, number_open_fireplaces character varying,
                                   photo_supply character varying, postcode character varying, posttown character varying,
                                   potential_energy_efficiency character varying, potential_energy_rating character varying,
                                   property_type character varying, report_type character varying,
                                   roof_description character varying, roof_energy_eff character varying,
                                   roof_env_eff character varying, secondheat_description character varying,
                                   sheating_energy_eff character varying, sheating_env_eff character varying,
                                   solar_water_heating_flag character varying, tenure character varying,
                                   total_floor_area character varying, transaction_type character varying,
                                   unheated_corridor_length character varying, walls_description character varying,
                                   walls_energy_eff character varying, walls_env_eff character varying,
                                   wind_turbine_count character varying, windows_description character varying,
                                   windows_energy_eff character varying, windows_env_eff character varying);

    SQL
  end

  def down
    execute "DROP VIEW vw_open_data_export"
  end
end
