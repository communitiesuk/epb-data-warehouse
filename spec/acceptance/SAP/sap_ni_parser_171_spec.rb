RSpec.describe "the parser and the SAP configuration (for Northern Ireland" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP (SAP NI 17.1)" do
    let(:rdsap) { Samples.xml "SAP-Schema-NI-17.1", "rdsap" }

    it "parses the document into the expected format" do
      expectation = { "calculation_software_version" => 4.1,
                      "calculation_software_name" => "Epc Reporter",
                      "sap_version" => 9.91,
                      "walls" =>
                        [{ "description" => "Cavity wall, as built, insulated (assumed)",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "roofs" =>
                        [{ "description" => "Pitched, 300+ mm loft insulation",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "floors" =>
                        [{ "description" => "Solid, no insulation (assumed)",
                           "energy_efficiency_rating" => 0,
                           "environmental_efficiency_rating" => 0 }],
                      "windows" =>
                        [{ "description" => "Fully double glazed",
                           "energy_efficiency_rating" => 3,
                           "environmental_efficiency_rating" => 3 }],
                      "main_heating" =>
                        [{ "description" => "Boiler and radiators, oil",
                           "energy_efficiency_rating" => 3,
                           "environmental_efficiency_rating" => 3 }],
                      "main_heating_controls" =>
                        [{ "description" => "Programmer, TRVs and bypass",
                           "energy_efficiency_rating" => 3,
                           "environmental_efficiency_rating" => 3 }],
                      "hot_water" =>
                        { "description" => "From main system, no cylinder thermostat",
                          "energy_efficiency_rating" => 2,
                          "environmental_efficiency_rating" => 1 },
                      "lighting" =>
                        { "description" => "No low energy lighting",
                          "energy_efficiency_rating" => 1,
                          "environmental_efficiency_rating" => 1 },
                      "secondary_heating" =>
                        { "description" => "Room heaters, dual fuel (mineral and wood)",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "End-terrace house",
                      "total_floor_area" => 65,
                      "has_fixed_air_conditioning" => "false",
                      "energy_rating_average" => 57,
                      "energy_rating_current" => 56,
                      "energy_rating_potential" => 73,
                      "environmental_impact_current" => 45,
                      "environmental_impact_potential" => 65,
                      "lzc_energy_sources" => [9],
                      "energy_consumption_current" => 297,
                      "energy_consumption_potential" => 184,
                      "co2_emissions_current" => { "quantity" => "tonnes per year", "value" => 4.7 },
                      "co2_emissions_potential" => { "quantity" => "tonnes per year", "value" => 2.9 },
                      "co2_emissions_current_per_floor_area" => { "quantity" => "kg/m2 per year", "value" => 72 },
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 75 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 38 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 545 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 369 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 271 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 141 },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_type" => "E",
                          "indicative_cost" => "£45",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 29 },
                          "energy_performance_rating" => 58,
                          "environmental_impact_rating" => 46,
                          "improvement_details" => { "improvement_number" => 35 } },
                        { "sequence" => 2,
                          "improvement_type" => "F",
                          "indicative_cost" => "£200 - £400",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 46 },
                          "energy_performance_rating" => 60,
                          "environmental_impact_rating" => 48,
                          "improvement_details" => { "improvement_number" => 4 } },
                        { "sequence" => 3,
                          "improvement_type" => "G",
                          "indicative_cost" => "£350 - £450",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 59 },
                          "energy_performance_rating" => 63,
                          "environmental_impact_rating" => 51,
                          "improvement_details" => { "improvement_number" => 14 } },
                        { "sequence" => 4,
                          "improvement_type" => "W",
                          "indicative_cost" => "£800 - £1,200",
                          "improvement_category" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 54 },
                          "energy_performance_rating" => 66,
                          "environmental_impact_rating" => 54,
                          "improvement_details" => { "improvement_number" => 47 } },
                        { "sequence" => 5,
                          "improvement_type" => "I",
                          "indicative_cost" => "£2,200 - £3,000",
                          "improvement_category" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 156 },
                          "energy_performance_rating" => 73,
                          "environmental_impact_rating" => 65,
                          "improvement_details" => { "improvement_number" => 20 } },
                        { "sequence" => 6,
                          "improvement_type" => "N",
                          "indicative_cost" => "£4,000 - £6,000",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 48 },
                          "energy_performance_rating" => 76,
                          "environmental_impact_rating" => 68,
                          "improvement_details" => { "improvement_number" => 19 } },
                        { "sequence" => 7,
                          "improvement_type" => "U",
                          "indicative_cost" => "£9,000 - £14,000",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 209 },
                          "energy_performance_rating" => 87,
                          "environmental_impact_rating" => 79,
                          "improvement_details" => { "improvement_number" => 34 } },
                        { "sequence" => 8,
                          "improvement_type" => "V",
                          "indicative_cost" => "£1,500 - £4,000",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 19 },
                          "energy_performance_rating" => 88,
                          "environmental_impact_rating" => 80,
                          "improvement_details" => { "improvement_number" => 44 } }],
                      "schema_version" => "LIG-16.0",
                      "habitable_room_count" => 5,
                      "heated_room_count" => 5,
                      "conservatory_type" => 1,
                      "glazed_area" => 1,
                      "property_type" => 0,
                      "built_form" => 3,
                      "extensions_count" => 0,
                      "percent_draughtproofed" => 100,
                      "measurement_type" => 1,
                      "sap_energy_source" =>
                       { "wind_turbines_terrain_type" => 2, "wind_turbines_count" => 0, "meter_type" => 2, "main_gas" => "N", "photovoltaic_supply" => { "percent_roof_area" => 0 } },
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
                             "main_heating_control" => 2107,
                             "boiler_flue_type" => 1,
                             "fan_flue_present" => "N",
                             "heat_emitter_type" => 1,
                             "main_heating_fraction" => 1,
                             "has_fghrs" => "N",
                             "main_heating_number" => 1 }],
                         "wwhrs" => { "rooms_with_bath_and_or_shower" => 1, "rooms_with_mixer_shower_no_bath" => 0, "rooms_with_bath_and_mixer_shower" => 1 },
                         "secondary_heating_type" => 632,
                         "secondary_fuel_type" => 9 },
                      "door_count" => 2,
                      "insulated_door_count" => 0,
                      "multiple_glazed_proportion" => 100,
                      "multiple_glazing_type" => 1,
                      "low_energy_lighting" => 0,
                      "fixed_lighting_outlets_count" => 9,
                      "low_energy_fixed_lighting_outlets_count" => 0,
                      "solar_water_heating" => "N",
                      "sap_building_parts" =>
                       [{ "construction_age_band" => "G",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 4,
                          "wall_thickness_measured" => "N",
                          "wall_dry_lined" => "N",
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "300mm+",
                          "floor_heat_loss" => 7,
                          "sap_floor_dimensions" =>
                           [{ "floor_construction" => 1, "floor_insulation" => 1, "total_floor_area" => 32.4, "room_height" => 2.4, "heat_loss_perimeter" => 16.2, "floor" => 0 },
                            { "total_floor_area" => 32.4, "room_height" => 2.32, "heat_loss_perimeter" => 16.2, "floor" => 1 }],
                          "building_part_number" => 1,
                          "identifier" => "Main Dwelling" }],
                      "open_fireplaces_count" => 0,
                      "bedf_revision_number" => 328,
                      "inspection_date" => "2013-04-13",
                      "report_type" => 2,
                      "completion_date" => "2013-04-14",
                      "registration_date" => "2013-04-14",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 1,
                      "seller_commission_report" => "Y",
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "tenure" => 1,
                      "transaction_type" => 5,
                      "scheme_assessor_id" => "SCHE020202",
                      "address_line_1" => "12 Lane Street",
                      "post_town" => "POSTTOWN",
                      "postcode" => "BT1 1AA",
                      "uprn" => 555_555_555 }

      expect(use_case.execute(xml: rdsap,
                              schema_type: "SAP-Schema-NI-17.1",
                              assessment_id: "8888-7777-6666-5555-4444")).to eq expectation
    end
  end

  context "when loading XML from SAP (SAP NI 17.1)" do
    let(:sap) { Samples.xml "SAP-Schema-NI-17.1", "sap" }

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.9,
                      "sap_data_version" => 9.81,
                      "bedf_revision_number" => 338,
                      "calculation_software_name" => "Elmhurst Energy Systems SAP2009 Calculator (Design System)",
                      "calculation_software_version" => "4.3.15.0",
                      "inspection_date" => "2013-07-11",
                      "report_type" => 3,
                      "completion_date" => "2013-07-11",
                      "registration_date" => "2013-07-11",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "transaction_type" => 6,
                      "tenure" => "ND",
                      "seller_commission_report" => "Y",
                      "property_type" => 2,
                      "scheme_assessor_id" => "SCHE023344",
                      "address_line_1" => 5,
                      "address_line_2" => "Street Lane",
                      "address_line_3" => "District",
                      "post_town" => "POSTTOWN",
                      "postcode" => "BT1 1AA",
                      "uprn" => 85_558_558_585,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "assessment_date" => "2013-06-10",
                      "lzc_energy_sources" => [9],
                      "walls" =>
                        [{ "description" => "Average thermal transmittance 0.27 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "roofs" =>
                        [{ "description" => "Average thermal transmittance 0.16 W/m²K",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "floors" =>
                        [{ "description" => "(other premises below)",
                           "energy_efficiency_rating" => 0,
                           "environmental_efficiency_rating" => 0 }],
                      "windows" =>
                        { "description" => "High performance glazing",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 },
                      "main_heating" =>
                        [{ "description" => "Boiler and radiators, mains gas",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "main_heating_controls" =>
                        [{ "description" => "Programmer, room thermostat and TRVs",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "secondary_heating" =>
                        { "description" => "Room heaters, electric",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                      "hot_water" =>
                        { "description" => "From main system",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "lighting" =>
                        { "description" => "Low energy lighting in 50% of fixed outlets",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "air_tightness" =>
                        { "description" => "Air permeability 5.1 m³/h.m² (as tested)",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "false",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Top-floor flat",
                      "total_floor_area" => 64,
                      "energy_rating_average" => 57,
                      "energy_rating_typical_newbuild" => 79,
                      "energy_rating_current" => 77,
                      "energy_rating_potential" => 78,
                      "environmental_impact_current" => 80,
                      "environmental_impact_potential" => 81,
                      "energy_consumption_current" => 133,
                      "energy_consumption_potential" => 127,
                      "co2_emissions_current" => 1.6,
                      "co2_emissions_potential" => 1.5,
                      "co2_emissions_current_per_floor_area" => 25,
                      "lighting_cost_current" => 68,
                      "lighting_cost_potential" => 45,
                      "heating_cost_current" => 295,
                      "heating_cost_potential" => 299,
                      "hot_water_cost_current" => 80,
                      "hot_water_cost_potential" => 80,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 1,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => 19,
                          "indicative_cost" => "£15",
                          "energy_performance_rating" => 78,
                          "environmental_impact_rating" => 81 }],
                      "data_type" => 2,
                      "schema_version" => "LIG-NI-17.0",
                      "built_form" => 1,
                      "living_area" => 30.7,
                      "orientation" => 8,
                      "conservatory_type" => 1,
                      "is_in_smoke_control_area" => "unknown",
                      "sap_flat_details" => { "level" => 3 },
                      "sap_opening_types" =>
                       [{ "name" => "Door", "data_source" => 2, "type" => 1, "glazing_type" => 1, "u_value" => 3 },
                        { "name" => "w01", "data_source" => 2, "type" => 4, "glazing_type" => 7, "solar_transmittance" => 0.63, "frame_factor" => 0.7, "u_value" => 1.8 },
                        { "name" => "RL", "data_source" => 2, "type" => 5, "glazing_type" => 7, "solar_transmittance" => 0.63, "frame_factor" => 0.7, "u_value" => 1.4 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2013,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "Door", "type" => "Door", "location" => "Walls (1)", "orientation" => 0, "width" => 1.69, "height" => 1 },
                            { "name" => "w01", "type" => "w01", "location" => "Walls (1)", "orientation" => 8, "width" => 2.62, "height" => 1 },
                            { "name" => "RL", "type" => "RL", "location" => "Roof (1)", "orientation" => 8, "width" => 0.78, "height" => 1 },
                            { "name" => "RL", "type" => "RL", "location" => "Roof (1)", "orientation" => 4, "width" => 1.56, "height" => 1 }],
                          "sap_floor_dimensions" => [{ "storey" => 1, "floor_type" => 3, "total_floor_area" => 64.03, "storey_height" => 3, "heat_loss_area" => 0, "u_value" => 0 }],
                          "sap_roofs" =>
                           [{ "name" => "Roof (1)", "description" => "Ceiling", "roof_type" => 2, "total_roof_area" => 37.39, "u_value" => 0.14 },
                            { "name" => "Roof (2)", "description" => "Slope", "roof_type" => 2, "total_roof_area" => 32.49, "u_value" => 0.18 }],
                          "sap_walls" =>
                           [{ "name" => "Walls (1)", "description" => "Exterior Wall", "wall_type" => 2, "total_wall_area" => 70.92, "u_value" => 0.27, "is_curtain_walling" => "false" },
                            { "name" => "Walls (2)", "description" => "Sheltered Wall", "wall_type" => 3, "total_wall_area" => 9.94, "u_value" => 0.27, "is_curtain_walling" => "false" }],
                          "sap_thermal_bridges" => { "thermal_bridge_code" => 4, "user_defined_y_value" => 0.08, "calculation_reference" => "2006 regulations" },
                          "thermal_mass_parameter" => 250 }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 2,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 5.14,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "boiler_index_number" => 10_244,
                             "main_fuel_type" => 1,
                             "main_heating_control" => 2106,
                             "heat_emitter_type" => 1,
                             "main_heating_flue_type" => 2,
                             "is_flue_fan_present" => "true",
                             "is_central_heating_pump_in_heated_space" => "true",
                             "is_interlocked_system" => "true",
                             "has_delayed_start_thermostat" => "false",
                             "load_or_weather_compensation" => 0 }],
                         "secondary_heating_category" => 10,
                         "secondary_heating_data_source" => 3,
                         "secondary_fuel_type" => 39,
                         "secondary_heating_code" => 691,
                         "has_fixed_air_conditioning" => "false",
                         "water_heating_code" => 901,
                         "water_fuel_type" => 1,
                         "has_hot_water_cylinder" => "false",
                         "thermal_store" => 1,
                         "has_solar_panel" => "false" },
                      "sap_energy_source" =>
                       { "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "fixed_lighting_outlets_count" => 12,
                         "low_energy_fixed_lighting_outlets_count" => 6,
                         "low_energy_fixed_lighting_outlets_percentage" => 50,
                         "electricity_tariff" => 1 } }

      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-NI-17.1",
                              assessment_id: "6666-5555-4444-3333-2222")).to eq expectation
    end
  end
end
