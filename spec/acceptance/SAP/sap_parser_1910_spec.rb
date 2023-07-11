RSpec.describe "the parser and the SAP configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading xml from SAP" do
    let(:sap) do
      Samples.xml("SAP-Schema-19.1.0")
    end

    it "parses the document in the expected format" do
      expectation = { "schema_version_original" => "SAP-Schema-19.0.0",
                      "sap_version" => 10.2,
                      "sap_data_version" => 10.2,
                      "calculation_software_name" => "SomeSoft SAP Calculator",
                      "calculation_software_version" => "13.05r16",
                      "user_interface_name" => "BRE SAP interface 10.2",
                      "user_interface_version" => "1.0.1-alpha",
                      "inspection_date" => "2022-05-09",
                      "report_type" => 3,
                      "completion_date" => "2022-05-09",
                      "registration_date" => "2022-05-09",
                      "status" => "entered",
                      "language_code" => 1,
                      "tenure" => 1,
                      "transaction_type" => 1,
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "SPEC000000",
                      "address_line_1" => "1 Some Street",
                      "address_line_2" => "Some Area",
                      "address_line_3" => "Some County",
                      "post_town" => "Whitbury",
                      "postcode" => "A0 0AA",
                      "uprn" => "UPRN-0000000001",
                      "region_code" => 16,
                      "country_code" => "ENG",
                      "assessment_date" => "2022-05-09",
                      "walls" => [{ "description" => "Average thermal transmittance 0.18 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "roofs" => [{ "description" => "Average thermal transmittance 0.13 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "floors" => [{ "description" => "Average thermal transmittance 0.12 W/m²K", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
                      "windows" =>
                       { "description" => "High performance glazing", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 },
                      "main_heating" =>
                       [{ "description" => "Boiler and radiators, electric",
                          "energy_efficiency_rating" => 3,
                          "environmental_efficiency_rating" => 2 }],
                      "main_heating_controls" =>
                       [{ "description" => "Programmer, room thermostat and TRVs",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 }],
                      "secondary_heating" =>
                       { "description" => "None", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 },
                      "hot_water" =>
                       { "description" => "From main system, waste water heat recovery",
                         "energy_efficiency_rating" => 4,
                         "environmental_efficiency_rating" => 3 },
                      "lighting" =>
                       { "description" => "Low energy lighting in 91% of fixed outlets",
                         "energy_efficiency_rating" => 5,
                         "environmental_efficiency_rating" => 5 },
                      "air_tightness" =>
                       { "description" => "Air permeability 2.0 m³/h.m² (assumed)", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Mid-terrace house",
                      "total_floor_area" => 165,
                      "multiple_glazed_percentage" => 100,
                      "energy_rating_average" => 60,
                      "energy_rating_current" => 72,
                      "energy_rating_potential" => 72,
                      "environmental_impact_current" => 94,
                      "environmental_impact_potential" => 96,
                      "energy_consumption_current" => 59,
                      "energy_consumption_potential" => 53,
                      "co2_emissions_current" => 2.4,
                      "co2_emissions_potential" => 1.4,
                      "co2_emissions_current_per_floor_area" => 5.6,
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 123.45 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 84.23 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 365.98 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 250.34 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 200.4 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 180.43 },
                      "renewable_heat_incentive" => { "rhi_new_dwelling" => { "space_heating" => 2666, "water_heating" => 2650 } },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 5,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "indicative_cost" => "£4,000 - £6,000",
                          "typical_saving" => { "currency" => "GBP", "value" => 88 },
                          "energy_performance_rating" => 74,
                          "environmental_impact_rating" => 94 },
                        { "improvement_category" => 5,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "indicative_cost" => "£9,000 - £14,000",
                          "sequence" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 88 },
                          "energy_performance_rating" => 80,
                          "environmental_impact_rating" => 96 }],
                      "sap_energy_source" =>
                       { "electricity_tariff" => 5, "wind_turbines" => [{ "wind_turbine_rotor_diameter" => 1.7, "wind_turbine_hub_height" => 3 }, { "wind_turbine_rotor_diameter" => 1.7, "wind_turbine_hub_height" => 3 }] },
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "electric_cpsu_operating_temperature" => 80,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 3,
                             "main_heating_code" => 192,
                             "main_fuel_type" => 47,
                             "main_heating_control" => 2106,
                             "is_condensing_boiler" => "false",
                             "combi_boiler_type" => 4,
                             "heat_emitter_type" => 1,
                             "is_central_heating_pump_in_heated_space" => "true",
                             "is_oil_pump_in_heated_space" => "false",
                             "is_interlocked_system" => "false",
                             "has_separate_delayed_start" => "true",
                             "is_main_heating_hetas_approved" => "false",
                             "has_fghrs" => "false",
                             "central_heating_pump_age" => 2 }],
                         "sap_community_heating_systems" =>
                          [{ "community_heating_distribution_loss_factor" => 1.26,
                             "community_heating_distribution_type" => 5,
                             "community_heating_use" => 3,
                             "heat_network_assessed_as_new" => "true",
                             "heat_network_existing" => "true",
                             "heat_network_index_number" => 496_402,
                             "sub_network_name" => "Test 1" }],
                         "secondary_heating_category" => 1,
                         "water_heating_code" => 901,
                         "water_fuel_type" => 39,
                         "thermal_store" => 1,
                         "is_heat_pump_assisted_by_immersion" => "false",
                         "is_immersion_for_summer_use" => "false",
                         "hot_water_store_size" => 600,
                         "has_hot_water_cylinder" => "true",
                         "hot_water_store_heat_loss_source" => 2,
                         "has_cylinder_thermostat" => "true",
                         "is_hot_water_separately_timed" => "false",
                         "shower_outlets" =>
                          [{ "shower_outlet_type" => 1, "shower_flow_rate" => 7, "shower_wwhrs" => 1 },
                           { "shower_outlet_type" => 1, "shower_flow_rate" => 7, "shower_wwhrs" => 2 }],
                         "instantaneous_wwhrs" => { "wwhrs_index_number1" => 491_123 },
                         "hot_water_store_heat_loss" => 2.45,
                         "has_fixed_air_conditioning" => "false" },
                      "sap_building_parts" =>
                       [{ "identifier" => "Main Dwelling",
                          "sap_thermal_bridges" =>
                           { "thermal_bridge_code" => 5,
                             "thermal_bridges" =>
                              [{ "thermal_bridge_type" => "E2", "length" => 15.5, "psi_value" => 0.3, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E3", "length" => 12.1, "psi_value" => 0.04, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E4", "length" => 52.1, "psi_value" => 0.05, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E5", "length" => 14.4, "psi_value" => 0.16, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E6", "length" => 25.8, "psi_value" => 0.07, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E10", "length" => 10.4, "psi_value" => 0.06, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E14", "length" => 5.4, "psi_value" => 0.06, "psi_value_source" => 3 },
                               { "thermal_bridge_type" => "E16", "length" => 5.8, "psi_value" => 0.09, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E17", "length" => 5.8, "psi_value" => -0.09, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "E18", "length" => 34, "psi_value" => 0.06, "psi_value_source" => 2 },
                               { "thermal_bridge_type" => "P1", "length" => 20.6, "psi_value" => 0.12, "psi_value_source" => 3 },
                               { "thermal_bridge_type" => "P2", "length" => 20.6, "psi_value" => 0, "psi_value_source" => 4 },
                               { "thermal_bridge_type" => "P4", "length" => 20.6, "psi_value" => 0.12, "psi_value_source" => 3 }] },
                          "building_part_number" => 1,
                          "construction_age_band" => "A",
                          "sap_floor_dimensions" =>
                           [{ "floor_type" => 2,
                              "storey" => 0,
                              "storey_height" => 2.8,
                              "total_floor_area" => 57.4,
                              "u_value" => 0.12,
                              "heat_loss_area" => 57.4,
                              "kappa_value" => 80 },
                            { "floor_type" => 3,
                              "storey" => 1,
                              "storey_height" => 3,
                              "total_floor_area" => 57.4,
                              "u_value" => 0,
                              "heat_loss_area" => 0,
                              "kappa_value" => 18,
                              "kappa_value_from_below" => 9 },
                            { "floor_type" => 3,
                              "storey" => 2,
                              "storey_height" => 2.7,
                              "total_floor_area" => 57.4,
                              "u_value" => 0,
                              "heat_loss_area" => 0,
                              "kappa_value" => 19,
                              "kappa_value_from_below" => 9 }],
                          "sap_openings" =>
                           [{ "location" => "Walls (1)", "name" => 1, "type" => "Doors", "height" => 2.25, "width" => 1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 2, "type" => "Doors", "height" => 2.1, "width" => 0.8, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 3, "type" => "Windows (2)", "height" => 2.7, "width" => 1.6, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 4, "type" => "Windows (1)", "height" => 1.75, "width" => 1.1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 5, "type" => "Windows (1)", "height" => 1.75, "width" => 1.1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 6, "type" => "Windows (1)", "height" => 1.85, "width" => 1.1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 7, "type" => "Windows (1)", "height" => 1.85, "width" => 1.1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 8, "type" => "Windows (1)", "height" => 1.8, "width" => 1.1, "orientation" => 3 },
                            { "location" => "Walls (1)", "name" => 9, "type" => "Windows (1)", "height" => 1.75, "width" => 1.1, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 10, "type" => "Windows (1)", "height" => 1.85, "width" => 1.1, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 11, "type" => "Windows (1)", "height" => 1.85, "width" => 1.1, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 12, "type" => "Windows (1)", "height" => 0.8, "width" => 0.6, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 13, "type" => "Windows (1)", "height" => 1.25, "width" => 0.8, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 14, "type" => "Windows (1)", "height" => 1.25, "width" => 0.8, "orientation" => 7 },
                            { "location" => "Walls (1)", "name" => 15, "type" => "Windows (1)", "height" => 1.25, "width" => 1.1, "orientation" => 7 }],
                          "sap_roofs" => [{ "name" => "Roof (1)", "u_value" => 0.13, "total_roof_area" => 57.4, "roof_type" => 2, "kappa_value" => 9 }],
                          "sap_walls" =>
                           [{ "name" => "Walls (1)",
                              "total_wall_area" => 111.34,
                              "u_value" => 0.18,
                              "wall_type" => 2,
                              "kappa_value" => 60,
                              "is_curtain_walling" => "false" },
                            { "name" => "Party wall",
                              "total_wall_area" => 167,
                              "u_value" => 0,
                              "wall_type" => 4,
                              "kappa_value" => 0,
                              "is_curtain_walling" => "false" },
                            { "name" => "Internal wall (1)",
                              "total_wall_area" => 320,
                              "u_value" => 0,
                              "wall_type" => 5,
                              "kappa_value" => 0,
                              "is_curtain_walling" => "false" }] }],
                      "sap_ventilation" =>
                       { "closed_flues_count" => 0,
                         "boilers_flues_count" => 0,
                         "other_flues_count" => 0,
                         "open_chimneys_count" => 0,
                         "blocked_chimneys_count" => 0,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 0,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "sheltered_sides_count" => 2,
                         "pressure_test" => 2,
                         "air_permeability" => 2,
                         "has_draught_lobby" => "false",
                         "is_mechanical_vent_approved_installer_scheme" => "true",
                         "ventilation_type" => 8,
                         "mechanical_ventilation_data_source" => 1,
                         "mechanical_vent_system_index_number" => 500_206,
                         "mechanical_vent_duct_placement" => 1,
                         "mechanical_vent_duct_insulation_level" => 2,
                         "mechanical_vent_duct_type" => 2,
                         "wet_rooms_count" => 2,
                         "wall_type" => 2 },
                      "sap_opening_types" =>
                       [{ "name" => "Doors", "data_source" => 2, "u_value" => 1.5, "type" => 1, "glazing_type" => 1, "isargonfilled" => "false" },
                        { "name" => "Windows (1)",
                          "data_source" => 3,
                          "u_value" => 1.4,
                          "type" => 4,
                          "glazing_type" => 11,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 1,
                          "solar_transmittance" => 0.57,
                          "frame_factor" => 0.7 },
                        { "name" => "Windows (2)",
                          "data_source" => 3,
                          "u_value" => 1.5,
                          "type" => 4,
                          "glazing_type" => 9,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 1,
                          "solar_transmittance" => 0.64,
                          "frame_factor" => 0.7 }],
                      "built_form" => 4,
                      "living_area" => 41.35,
                      "lowest_storey_area" => 57.4,
                      "orientation" => 0,
                      "cold_water_source" => 1,
                      "windows_overshading" => 2,
                      "is_in_smoke_control_area" => "unknown",
                      "sap_lighting" =>
                       [[{ "lighting_outlets" => 1, "lighting_efficacy" => 11.2, "lighting_power" => 60 },
                         { "lighting_outlets" => 10, "lighting_efficacy" => 66.9, "lighting_power" => 14 }]],
                      "conservatory_type" => 1,
                      "terrain_type" => 1,
                      "is_dwelling_export_capable" => "true",
                      "gas_smart_meter_present" => "false",
                      "electricity_smart_meter_present" => "false",
                      "data_type" => 1 }

      response = use_case.execute(xml: sap,
                                  schema_type: "SAP-Schema-19.1.0",
                                  assessment_id: "0000-0000-0000-0000-0000")

      expect(response).to eq(expectation)
    end
  end
end
