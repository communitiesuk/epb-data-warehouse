RSpec.describe "the parser and the SAP configuration (for Northern Ireland)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from SAP (NI)" do
    let(:sap) do
      Samples.xml "SAP-Schema-NI-17.3"
    end

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.9,
                      "bedf_revision_number" => 372,
                      "calculation_software_name" => "Elmhurst Energy Systems Design SAP 2009",
                      "calculation_software_version" => "4.03r03",
                      "inspection_date" => "2015-01-29",
                      "report_type" => 3,
                      "completion_date" => "2015-01-29",
                      "registration_date" => "2015-01-29",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "transaction_type" => 6,
                      "tenure" => "ND",
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "EMP/000006",
                      "address_line_1" => "1b Address Lane",
                      "address_line_2" => "Localtion Place",
                      "post_town" => "Town",
                      "postcode" => "BT1 1AA",
                      "uprn" => 0,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "assessment_date" => "2014-05-20",
                      "walls" =>
                       [{ "description" => "Average thermal transmittance 0.21 W/m²K",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
                      "roofs" =>
                       [{ "description" => "Average thermal transmittance 0.11 W/m²K",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
                      "floors" =>
                       [{ "description" => "Average thermal transmittance 0.13 W/m²K",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
                      "windows" =>
                       { "description" => "High performance glazing",
                         "energy_efficiency_rating" => 5,
                         "environmental_efficiency_rating" => 5 },
                      "main_heating" =>
                       [{ "description" => "Boiler and radiators, oil",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 }],
                      "main_heating_controls" =>
                       [{ "description" => "Time and temperature zone control",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
                      "secondary_heating" =>
                       { "description" => "Room heaters, wood logs",
                         "energy_efficiency_rating" => 0,
                         "environmental_efficiency_rating" => 0 },
                      "hot_water" =>
                       { "description" => "From main system",
                         "energy_efficiency_rating" => 3,
                         "environmental_efficiency_rating" => 3 },
                      "lighting" =>
                       { "description" => "Low energy lighting in all fixed outlets",
                         "energy_efficiency_rating" => 5,
                         "environmental_efficiency_rating" => 5 },
                      "air_tightness" =>
                       { "description" => "Air permeability 3.2 m³/h.m² (as tested)",
                         "energy_efficiency_rating" => 4,
                         "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Semi-detached house",
                      "total_floor_area" => 107,
                      "energy_rating_average" => 60,
                      "energy_rating_typical_newbuild" => 82,
                      "energy_rating_current" => 83,
                      "energy_rating_potential" => 83,
                      "environmental_impact_current" => 81,
                      "environmental_impact_potential" => 81,
                      "energy_consumption_current" => 96,
                      "energy_consumption_potential" => 96,
                      "co2_emissions_current" => 2.2,
                      "co2_emissions_potential" => 2.2,
                      "co2_emissions_current_per_floor_area" => 21,
                      "lighting_cost_current" => 70,
                      "lighting_cost_potential" => 70,
                      "heating_cost_current" => 311,
                      "heating_cost_potential" => 311,
                      "hot_water_cost_current" => 158,
                      "hot_water_cost_potential" => 158,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 3,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "typical_saving" => 65,
                          "indicative_cost" => "£4,000 - £6,000",
                          "energy_performance_rating" => 85,
                          "environmental_impact_rating" => 83 },
                        { "sequence" => 2,
                          "improvement_category" => 3,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => 254,
                          "indicative_cost" => "£9,000 - £14,000",
                          "energy_performance_rating" => 94,
                          "environmental_impact_rating" => 91 }],
                      "lzc_energy_sources" => [4],
                      "data_type" => 2,
                      "schema_version" => "LIG-17.3",
                      "built_form" => 2,
                      "living_area" => 18.77,
                      "orientation" => 5,
                      "conservatory_type" => 1,
                      "is_in_smoke_control_area" => "unknown",
                      "sap_opening_types" =>
                       [{ "name" => "Windows",
                          "data_source" => 2,
                          "type" => 4,
                          "glazing_type" => 7,
                          "solar_transmittance" => 0.63,
                          "frame_factor" => 0.7,
                          "u_value" => 1.4 },
                        { "name" => "Door",
                          "data_source" => 3,
                          "type" => 2,
                          "glazing_type" => 7,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 2,
                          "u_value" => 2.35 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2014,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "Front Door",
                              "type" => "Door",
                              "location" => "Walls (1)",
                              "orientation" => 0,
                              "width" => 2.94,
                              "height" => 1 },
                            { "name" => "Front Windows",
                              "type" => "Windows",
                              "location" => "Walls (1)",
                              "orientation" => 5,
                              "width" => 5.665,
                              "height" => 1 },
                            { "name" => "Back Windows",
                              "type" => "Windows",
                              "location" => "Walls (1)",
                              "orientation" => 1,
                              "width" => 3.62,
                              "height" => 1 },
                            { "name" => "Left  Side Windows",
                              "type" => "Windows",
                              "location" => "Walls (1)",
                              "orientation" => 7,
                              "width" => 3.285,
                              "height" => 1 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0,
                              "description" => "Heat Loss Floor 1",
                              "floor_type" => 2,
                              "total_floor_area" => 53.68,
                              "storey_height" => 2.55,
                              "heat_loss_area" => 53.68,
                              "u_value" => 0.13,
                              "kappa_value" => 110 },
                            { "storey" => 1,
                              "floor_type" => 3,
                              "total_floor_area" => 53.68,
                              "storey_height" => 2.77,
                              "heat_loss_area" => 0,
                              "u_value" => 0 }],
                          "sap_roofs" =>
                           [{ "name" => "Roof (1)",
                              "description" => "Plain Flat Ceilings",
                              "roof_type" => 2,
                              "total_roof_area" => 53.68,
                              "u_value" => 0.11,
                              "kappa_value" => 9 }],
                          "sap_walls" =>
                           [{ "name" => "Walls (1)",
                              "description" => "Main Wall Type",
                              "wall_type" => 2,
                              "total_wall_area" => 111.72,
                              "u_value" => 0.21,
                              "kappa_value" => 190,
                              "is_curtain_walling" => "false" },
                            { "name" => "Party wall (1)",
                              "wall_type" => 4,
                              "total_wall_area" => 46.82,
                              "u_value" => 0,
                              "kappa_value" => 180 },
                            { "name" => "Internal wall (1)",
                              "wall_type" => 5,
                              "total_wall_area" => 25.89,
                              "u_value" => 0,
                              "kappa_value" => 100 },
                            { "name" => "Internal wall (2)",
                              "wall_type" => 5,
                              "total_wall_area" => 37,
                              "u_value" => 0,
                              "kappa_value" => 9 }],
                          "sap_thermal_bridges" =>
                           { "thermal_bridge_code" => 5,
                             "thermal_bridges" =>
                              [{ "thermal_bridge_type" => 2,
                                 "length" => 11.6,
                                 "psi_value" => 0.3,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 3,
                                 "length" => 10.2,
                                 "psi_value" => 0.04,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 4,
                                 "length" => 28.2,
                                 "psi_value" => 0.05,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 5,
                                 "length" => 21,
                                 "psi_value" => 0.16,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 6,
                                 "length" => 21,
                                 "psi_value" => 0.07,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 10,
                                 "length" => 12.2,
                                 "psi_value" => 0.06,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 12,
                                 "length" => 8.1,
                                 "psi_value" => 0.24,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 14,
                                 "length" => 10.64,
                                 "psi_value" => 0.09,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 16,
                                 "length" => 10.64,
                                 "psi_value" => 0.06,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 21,
                                 "length" => 8.1,
                                 "psi_value" => 0.08,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 22,
                                 "length" => 8.1,
                                 "psi_value" => 0,
                                 "psi_value_source" => 2 },
                               { "thermal_bridge_type" => 24,
                                 "length" => 8.1,
                                 "psi_value" => 0.12,
                                 "psi_value_source" => 2 }] } }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 1,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 4,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 3.17,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "boiler_index_number" => 15_860,
                             "main_fuel_type" => 4,
                             "main_heating_control" => 2110,
                             "heat_emitter_type" => 1,
                             "main_heating_flue_type" => 1,
                             "is_flue_fan_present" => "true",
                             "is_central_heating_pump_in_heated_space" => "false",
                             "is_oil_pump_in_heated_space" => "false",
                             "is_interlocked_system" => "true",
                             "has_delayed_start_thermostat" => "false",
                             "load_or_weather_compensation" => 0 }],
                         "secondary_heating_category" => 10,
                         "secondary_heating_data_source" => 3,
                         "secondary_fuel_type" => 20,
                         "secondary_heating_code" => 631,
                         "is_secondary_heating_hetas_approved" => "true",
                         "secondary_heating_flue_type" => 3,
                         "has_fixed_air_conditioning" => "false",
                         "water_heating_code" => 901,
                         "water_fuel_type" => 4,
                         "has_hot_water_cylinder" => "true",
                         "thermal_store" => 1,
                         "hot_water_store_size" => 150,
                         "hot_water_store_heat_loss_source" => 3,
                         "hot_water_store_insulation_type" => 1,
                         "hot_water_store_insulation_thickness" => 80,
                         "is_primary_pipework_insulated" => "true",
                         "has_cylinder_thermostat" => "true",
                         "is_cylinder_in_heated_space" => "true",
                         "is_hot_water_separately_timed" => "true",
                         "has_solar_panel" => "false" },
                      "sap_energy_source" =>
                       { "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "fixed_lighting_outlets_count" => 20,
                         "low_energy_fixed_lighting_outlets_count" => 20,
                         "low_energy_fixed_lighting_outlets_percentage" => 100,
                         "electricity_tariff" => 1 } }
      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-NI-17.3",
                              assessment_id: "2222-0000-3333-5555-4444")).to eq(expectation)
    end
  end
end
