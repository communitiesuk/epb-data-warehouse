RSpec.describe "the parser and the SAP configuration (for Northern Ireland)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP (SAP NI 15.0)" do
    let(:rdsap) { Samples.xml "SAP-Schema-NI-15.0", "rdsap" }

    it "parses the document into the expected format" do
      expectation = { "calculation_software_version" => 4.0,
                      "calculation_software_name" => "Epc Reporter",
                      "sap_version" => 9.9,
                      "walls" => [{ "description" => "Cavity wall, as built, insulated (assumed)", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
                      "roofs" =>
                       [{ "description" => "Roof room(s), insulated", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 },
                        { "description" => "Pitched, 300+ mm loft insulation", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "floors" => [{ "description" => "Solid, limited insulation (assumed)", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 }],
                      "windows" => [{ "description" => "Fully double glazed", "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 3 }],
                      "main_heating" => [{ "description" => "Boiler and radiators, oil", "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 3 }],
                      "main_heating_controls" => [{ "description" => "Programmer, no room thermostat", "energy_efficiency_rating" => 1, "environmental_efficiency_rating" => 1 }],
                      "hot_water" => { "description" => "From main system, no cylinder thermostat", "energy_efficiency_rating" => 2, "environmental_efficiency_rating" => 1 },
                      "lighting" => { "description" => "No low energy lighting", "energy_efficiency_rating" => 1, "environmental_efficiency_rating" => 1 },
                      "secondary_heating" => { "description" => "Room heaters, electric", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 },
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Detached bungalow",
                      "total_floor_area" => 155,
                      "has_fixed_air_conditioning" => "false",
                      "energy_rating_current" => 53,
                      "energy_rating_potential" => 69,
                      "environmental_impact_current" => 44,
                      "environmental_impact_potential" => 61,
                      "energy_consumption_current" => { "quantity" => "kWh/m2 per year", "value" => 238 },
                      "energy_consumption_potential" => { "quantity" => "kWh/m2 per year", "value" => 157 },
                      "co2_emissions_current" => { "quantity" => "tonnes per year", "value" => 8.8 },
                      "co2_emissions_potential" => { "quantity" => "tonnes per year", "value" => 5.8 },
                      "co2_emissions_current_per_floor_area" => { "quantity" => "kg/m2 per year", "value" => 57 },
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 141 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 70 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 1202 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 844 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 271 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 151 },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_type" => "E",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 49 },
                          "indicative_cost" => "£35",
                          "energy_performance_rating" => 55,
                          "environmental_impact_rating" => 44,
                          "improvement_details" => { "improvement_number" => 35 } },
                        { "sequence" => 2,
                          "improvement_type" => "F",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 36 },
                          "indicative_cost" => "£200 - £400",
                          "energy_performance_rating" => 56,
                          "environmental_impact_rating" => 46,
                          "improvement_details" => { "improvement_number" => 4 } },
                        { "sequence" => 3,
                          "improvement_type" => "G",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 235 },
                          "indicative_cost" => "£350 - £450",
                          "energy_performance_rating" => 63,
                          "environmental_impact_rating" => 53,
                          "improvement_details" => { "improvement_number" => 12 } },
                        { "sequence" => 4,
                          "improvement_type" => "I",
                          "improvement_category" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 228 },
                          "indicative_cost" => "£1,500 - £3,500",
                          "energy_performance_rating" => 69,
                          "environmental_impact_rating" => 61,
                          "improvement_details" => { "improvement_number" => 20 } },
                        { "sequence" => 5,
                          "improvement_type" => "N",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 50 },
                          "indicative_cost" => "£4,000 - £6,000",
                          "energy_performance_rating" => 71,
                          "environmental_impact_rating" => 63,
                          "improvement_details" => { "improvement_number" => 19 } },
                        { "sequence" => 6,
                          "improvement_type" => "U",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 219 },
                          "indicative_cost" => "£11,000 - £20,000",
                          "energy_performance_rating" => 77,
                          "environmental_impact_rating" => 69,
                          "improvement_details" => { "improvement_number" => 34 } }],
                      "schema_version" => "LIG-15.0",
                      "habitable_room_count" => 5,
                      "heated_room_count" => 5,
                      "conservatory_type" => 1,
                      "glazed_area" => 1,
                      "property_type" => 1,
                      "built_form" => 1,
                      "extensions_count" => 0,
                      "measurement_type" => 1,
                      "sap_energy_source" =>
                       { "wind_turbines_terrain_type" => 2, "photovoltaic_supply" => { "percent_roof_area" => 0 }, "wind_turbines_count" => 0, "meter_type" => 2, "main_gas" => "N" },
                      "mechanical_ventilation" => 0,
                      "sap_heating" =>
                       { "has_fixed_air_conditioning" => "false",
                         "cylinder_size" => 2,
                         "water_heating_code" => 901,
                         "water_heating_fuel" => 28,
                         "cylinder_insulation_type" => 1,
                         "cylinder_insulation_thickness" => 38,
                         "cylinder_thermostat" => "N",
                         "main_heating_details" =>
                          [{ "main_heating_data_source" => 2,
                             "main_heating_category" => 2,
                             "main_fuel_type" => 28,
                             "sap_main_heating_code" => 125,
                             "main_heating_control" => 2102,
                             "boiler_flue_type" => 1,
                             "fan_flue_present" => "N",
                             "heat_emitter_type" => 1,
                             "main_heating_fraction" => 1,
                             "main_heating_number" => 1 }],
                         "secondary_heating_type" => 691,
                         "secondary_fuel_type" => 29 },
                      "multiple_glazed_proportion" => 100,
                      "multiple_glazing_type" => 1,
                      "low_energy_lighting" => 0,
                      "fixed_lighting_outlets_count" => 14,
                      "low_energy_fixed_lighting_outlets_count" => 0,
                      "solar_water_heating" => "N",
                      "sap_building_parts" =>
                       [{ "construction_age_band" => "H",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 4,
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "300mm+",
                          "floor_heat_loss" => 7,
                          "sap_floor_dimensions" =>
                           [{ "floor_construction" => 1, "floor_insulation" => 1, "total_floor_area" => 95.42, "room_height" => 2.5, "heat_loss_perimeter" => 41.4, "floor" => 0 }],
                          "sap_room_in_roof" => { "construction_age_band" => "H", "insulation" => 4, "roof_insulation_thickness" => "300mm+", "floor_area" => 59.52 },
                          "building_part_number" => 1,
                          "identifier" => "Main Dwelling" }],
                      "open_fireplaces_count" => 0,
                      "bedf_revision_number" => 317,
                      "inspection_date" => "2012-02-09",
                      "report_type" => 2,
                      "completion_date" => "2012-03-31",
                      "registration_date" => "2012-03-31",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 1,
                      "seller_commission_report" => "Y",
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "transaction_type" => 5,
                      "scheme_assessor_id" => "TEST000000",
                      "address_line_1" => "17, Street Lodge",
                      "post_town" => "Town",
                      "postcode" => "BT1 1AA",
                      "uprn" => { "xmlns" => "DCLG-HIP", "value" => 0 } }

      result = use_case.execute(xml: rdsap,
                                schema_type: "SAP-Schema-NI-15.0",
                                assessment_id: "1234-1234-1234-1234-1234")
      expect(result).to eq expectation
    end
  end

  context "when loading XML from SAP (SAP NI 15.0)" do
    let(:sap) { Samples.xml "SAP-Schema-NI-15.0", "sap" }

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.81,
                      "bedf_revision_number" => 317,
                      "calculation_software_name" => "Elmhurst Energy Systems SAP Calculator",
                      "calculation_software_version" => "Version: EES SAP 2005.018.04, November 2011",
                      "inspection_date" => "2012-03-30",
                      "report_type" => 3,
                      "completion_date" => "2012-03-30",
                      "registration_date" => "2012-03-30",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "transaction_type" => 6,
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "TEST00000",
                      "address_line_1" => "3, Street Close",
                      "post_town" => "FERGUS",
                      "postcode" => "BT1 1AA",
                      "uprn" => 0,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "assessment_date" => "2012-03-30",
                      "walls" => [{ "description" => "Average thermal transmittance 0.28 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "roofs" => [{ "description" => "Average thermal transmittance 0.15 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "floors" => [{ "description" => "Average thermal transmittance 0.17 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "windows" => { "description" => "High performance glazing", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 },
                      "main_heating" => [{ "description" => "Boiler and radiators, mains gas", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "main_heating_controls" => [{ "description" => "Time and temperature zone control", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
                      "secondary_heating" => { "description" => "Room heaters, mains gas", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 },
                      "hot_water" => { "description" => "From main system", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 },
                      "lighting" => { "description" => "Low energy lighting in 38% of fixed outlets", "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 3 },
                      "air_tightness" => { "description" => "Air permeability 4.7 m³/h.m² (as tested)", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "false",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Detached house",
                      "total_floor_area" => 136,
                      "energy_rating_current" => 81,
                      "energy_rating_potential" => 82,
                      "environmental_impact_current" => 79,
                      "environmental_impact_potential" => 80,
                      "energy_consumption_current" => 124,
                      "energy_consumption_potential" => 118,
                      "co2_emissions_current" => 2.8,
                      "co2_emissions_potential" => 2.7,
                      "co2_emissions_current_per_floor_area" => 20,
                      "lighting_cost_current" => 125,
                      "lighting_cost_potential" => 77,
                      "heating_cost_current" => 401,
                      "heating_cost_potential" => 408,
                      "hot_water_cost_current" => 132,
                      "hot_water_cost_potential" => 132,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 1,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => 41,
                          "energy_performance_rating" => 82,
                          "environmental_impact_rating" => 80 },
                        { "sequence" => 2,
                          "improvement_category" => 3,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => 212,
                          "energy_performance_rating" => 90,
                          "environmental_impact_rating" => 87 }],
                      "data_type" => 2,
                      "schema_version" => "LIG-15.0",
                      "built_form" => 1,
                      "living_area" => 16.92,
                      "orientation" => 0,
                      "conservatory_type" => 1,
                      "has_special_feature" => "false",
                      "is_in_smoke_control_area" => "unknown",
                      "sap_opening_types" =>
                       [{ "name" => "Doors (1)",
                          "description" => "front",
                          "data_source" => 3,
                          "type" => 2,
                          "glazing_type" => 6,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 2,
                          "u_value" => 2.35 },
                        { "name" => "Doors (2)",
                          "description" => "back",
                          "data_source" => 3,
                          "type" => 2,
                          "glazing_type" => 4,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 2,
                          "u_value" => 2.45 },
                        { "name" => "Windows (1)",
                          "description" => "side 2",
                          "data_source" => 2,
                          "type" => 4,
                          "glazing_type" => 4,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 2,
                          "solar_transmittance" => 0.72,
                          "frame_factor" => 0.7,
                          "u_value" => 1.6 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2012,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "front", "type" => "Doors (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 1.91, "height" => 1 },
                            { "name" => "back", "type" => "Doors (2)", "location" => "Walls (1)", "orientation" => 0, "width" => 1.91, "height" => 1 },
                            { "name" => "side 2", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 7.25, "height" => 1 },
                            { "name" => "front", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 11.91, "height" => 1 },
                            { "name" => "side 1", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 7.68, "height" => 1 },
                            { "name" => "back", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 12.03, "height" => 1 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0, "floor_type" => 2, "total_floor_area" => 74, "storey_height" => 2.4, "heat_loss_area" => 74, "u_value" => 0.17 },
                            { "storey" => 1, "floor_type" => 3, "total_floor_area" => 62, "storey_height" => 2.72, "heat_loss_area" => 0, "u_value" => 0 }],
                          "sap_exposed_roofs" => { "sap_exposed_roof" => { "name" => "Roof (3)", "total_roof_area" => 13.11, "u_value" => 0.19 } },
                          "sap_exposed_walls" =>
                           { "sap_exposed_wall" => { "name" => "Walls (1)", "wall_type" => 2, "total_wall_area" => 183.59, "u_value" => 0.28, "is_curtain_walling" => "false" } } }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 1,
                         "fans_vents_count" => 5,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 4.69,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_category" => 2,
                         "main_heating_data_source" => 1,
                         "boiler_index_number" => 15_425,
                         "combi_boiler_type" => 1,
                         "main_fuel_type" => 1,
                         "main_heating_control" => 2110,
                         "water_heating_code" => 901,
                         "water_fuel_type" => 1,
                         "has_hot_water_cylinder" => "false",
                         "heat_emitter_type" => 1,
                         "main_heating_flue_type" => 2,
                         "is_flue_fan_present" => "true",
                         "is_central_heating_pump_in_heated_space" => "true",
                         "is_interlocked_system" => "true",
                         "has_delayed_start_thermostat" => "false",
                         "load_or_weather_compensation" => 0,
                         "secondary_heating_category" => 10,
                         "secondary_heating_data_source" => 2,
                         "secondary_fuel_type" => 1,
                         "secondary_heating_make_model" => "x",
                         "secondary_heating_test_method" => "BS EN 613",
                         "secondary_heating_efficiency" => 40,
                         "secondary_heating_flue_type" => 1,
                         "has_fixed_air_conditioning" => "false",
                         "has_solar_panel" => "false" },
                      "sap_energy_source" =>
                       { "pv_peak_power" => 0,
                         "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "low_energy_fixed_lighting_outlets_percentage" => 38,
                         "electricity_tariff" => 1 } }

      result = use_case.execute(xml: sap,
                                schema_type: "SAP-Schema-NI-15.0",
                                assessment_id: "1234-1234-1234-1234-1234")
      expect(result).to eq expectation
    end
  end
end
