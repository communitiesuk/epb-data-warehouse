RSpec.describe "the parser and the SAP configuration (for Northern Ireland)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP (SAP NI 17.2)" do
    let(:rdsap) { Samples.xml "SAP-Schema-NI-17.2", "rdsap" }

    it "parses the document into the expected format" do
      expectation = { "calculation_software_version" => 4.4,
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
                        [{ "description" => "Solid, limited insulation (assumed)",
                           "energy_efficiency_rating" => 0,
                           "environmental_efficiency_rating" => 0 }],
                      "windows" =>
                        [{ "description" => "Fully double glazed",
                           "energy_efficiency_rating" => 3,
                           "environmental_efficiency_rating" => 3 }],
                      "main_heating" =>
                        [{ "description" => "Boiler and radiators, oil",
                           "energy_efficiency_rating" => 2,
                           "environmental_efficiency_rating" => 2 }],
                      "main_heating_controls" =>
                        [{ "description" => "Programmer, room thermostat and TRVs",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "hot_water" =>
                        { "description" => "From main system",
                          "energy_efficiency_rating" => 2,
                          "environmental_efficiency_rating" => 2 },
                      "lighting" =>
                        { "description" => "Low energy lighting in 23% of fixed outlets",
                          "energy_efficiency_rating" => 2,
                          "environmental_efficiency_rating" => 2 },
                      "secondary_heating" =>
                        { "description" => "None",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                      "lzc_energy_sources" => [9],
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Detached bungalow",
                      "total_floor_area" => 234,
                      "has_fixed_air_conditioning" => "false",
                      "energy_rating_average" => 57,
                      "energy_rating_current" => 55,
                      "energy_rating_potential" => 73,
                      "environmental_impact_current" => 43,
                      "environmental_impact_potential" => 64,
                      "energy_consumption_current" => 212,
                      "energy_consumption_potential" => 128,
                      "co2_emissions_current" => { "quantity" => "tonnes per year", "value" => 12 },
                      "co2_emissions_potential" => { "quantity" => "tonnes per year", "value" => 7.5 },
                      "co2_emissions_current_per_floor_area" => { "quantity" => "kg/m2 per year", "value" => 53 },
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 173 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 98 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 2258 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 1362 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 314 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 197 },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_type" => "E",
                          "indicative_cost" => "£100",
                          "improvement_category" => 1,
                          "typical_saving" => { "currency" => "GBP", "value" => 49 },
                          "energy_performance_rating" => 56,
                          "environmental_impact_rating" => 44,
                          "improvement_details" => { "improvement_number" => 35 } },
                        { "sequence" => 2,
                          "improvement_type" => "W",
                          "indicative_cost" => "£800 - £1,200",
                          "improvement_category" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 233 },
                          "energy_performance_rating" => 60,
                          "environmental_impact_rating" => 47,
                          "improvement_details" => { "improvement_number" => 47 } },
                        { "sequence" => 3,
                          "improvement_type" => "I",
                          "indicative_cost" => "£2,200 - £3,000",
                          "improvement_category" => 2,
                          "typical_saving" => { "currency" => "GBP", "value" => 807 },
                          "energy_performance_rating" => 73,
                          "environmental_impact_rating" => 64,
                          "improvement_details" => { "improvement_number" => 37 } },
                        { "sequence" => 4,
                          "improvement_type" => "N",
                          "indicative_cost" => "£4,000 - £6,000",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 67 },
                          "energy_performance_rating" => 74,
                          "environmental_impact_rating" => 65,
                          "improvement_details" => { "improvement_number" => 19 } },
                        { "sequence" => 5,
                          "improvement_type" => "U",
                          "indicative_cost" => "£9,000 - £14,000",
                          "improvement_category" => 3,
                          "typical_saving" => { "currency" => "GBP", "value" => 226 },
                          "energy_performance_rating" => 79,
                          "environmental_impact_rating" => 70,
                          "improvement_details" => { "improvement_number" => 34 } }],
                      "schema_version" => "LIG-16.0",
                      "habitable_room_count" => 8,
                      "heated_room_count" => 8,
                      "conservatory_type" => 1,
                      "glazed_area" => 1,
                      "property_type" => 1,
                      "built_form" => 1,
                      "extensions_count" => 0,
                      "percent_draughtproofed" => 100,
                      "measurement_type" => 1,
                      "sap_energy_source" => { "wind_turbines_terrain_type" => 2, "wind_turbines_count" => 0, "meter_type" => 2, "main_gas" => "N", "photovoltaic_supply" => { "percent_roof_area" => 0 } },
                      "mechanical_ventilation" => 0,
                      "sap_heating" =>
                       { "has_fixed_air_conditioning" => "false",
                         "cylinder_size" => 3,
                         "water_heating_code" => 901,
                         "water_heating_fuel" => 28,
                         "cylinder_insulation_type" => 1,
                         "cylinder_insulation_thickness" => 38,
                         "cylinder_thermostat" => "Y",
                         "main_heating_details" =>
                          [{ "main_heating_data_source" => 2,
                             "main_heating_category" => 2,
                             "main_fuel_type" => 28,
                             "sap_main_heating_code" => 139,
                             "main_heating_control" => 2106,
                             "boiler_flue_type" => 1,
                             "fan_flue_present" => "N",
                             "heat_emitter_type" => 1,
                             "main_heating_fraction" => 1,
                             "has_fghrs" => "N",
                             "main_heating_number" => 1 }],
                         "wwhrs" =>
                           { "rooms_with_bath_and_or_shower" => 3,
                             "rooms_with_mixer_shower_no_bath" => 1,
                             "rooms_with_bath_and_mixer_shower" => 1 } },
                      "door_count" => 2,
                      "insulated_door_count" => 0,
                      "multiple_glazed_proportion" => 100,
                      "multiple_glazing_type" => 1,
                      "low_energy_lighting" => 23,
                      "fixed_lighting_outlets_count" => 26,
                      "low_energy_fixed_lighting_outlets_count" => 6,
                      "solar_water_heating" => "N",
                      "sap_building_parts" =>
                       [{ "construction_age_band" => "H",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 4,
                          "wall_thickness_measured" => "N",
                          "wall_dry_lined" => "N",
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "300mm+",
                          "floor_heat_loss" => 7,
                          "sap_floor_dimensions" =>
                            [{ "floor_construction" => 1,
                               "floor_insulation" => 1,
                               "total_floor_area" => 233.71,
                               "room_height" => 2.57,
                               "heat_loss_perimeter" => 82.2,
                               "floor" => 0 }],
                          "building_part_number" => 1,
                          "identifier" => "Main Dwelling" }],
                      "open_fireplaces_count" => 0,
                      "bedf_revision_number" => 358,
                      "inspection_date" => "2013-08-19",
                      "report_type" => 2,
                      "completion_date" => "2013-09-07",
                      "registration_date" => "2013-09-07",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 1,
                      "seller_commission_report" => "Y",
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "tenure" => 1,
                      "transaction_type" => 5,
                      "scheme_assessor_id" => "SCHE101010",
                      "address_line_1" => "30 Street Road",
                      "address_line_2" => "Smalltown",
                      "post_town" => "POSTTOWN",
                      "postcode" => "BT1 1AA",
                      "uprn" => 5_555_555_555 }

      expect(use_case.execute(xml: rdsap,
                              schema_type: "SAP-Schema-NI-17.2",
                              assessment_id: "4444-5555-6666-7777-8888")).to eq(expectation)
    end
  end

  context "when loading XML from SAP (SAP NI 17.2)" do
    let(:sap) { Samples.xml "SAP-Schema-NI-17.2", "sap" }

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.9,
                      "sap_data_version" => 9.81,
                      "bedf_revision_number" => 353,
                      "calculation_software_name" => "Elmhurst Energy Systems Design SAP 2009",
                      "calculation_software_version" => "1.11r08",
                      "inspection_date" => "2014-03-25",
                      "report_type" => 3,
                      "completion_date" => "2014-03-25",
                      "registration_date" => "2014-03-25",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "transaction_type" => 6,
                      "tenure" => "ND",
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "SCHE010101",
                      "address_line_1" => "32 Street Lane",
                      "address_line_2" => "District",
                      "post_town" => "POSTTOWN",
                      "postcode" => "BT1 1AA",
                      "uprn" => 55_555_555_555,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "assessment_date" => "2014-02-25",
                      "lzc_energy_sources" => [9],
                      "walls" =>
                        [{ "description" => "Average thermal transmittance 0.30 W/m²K",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "roofs" =>
                        [{ "description" => "Average thermal transmittance 0.14 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "floors" =>
                        [{ "description" => "Average thermal transmittance 0.17 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
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
                        { "description" => "None",
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
                        { "description" => "Air permeability 4.6 m³/h.m² (as tested)",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "false",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Mid-terrace house",
                      "total_floor_area" => 87,
                      "energy_rating_average" => 57,
                      "energy_rating_typical_newbuild" => 83,
                      "energy_rating_current" => 80,
                      "energy_rating_potential" => 81,
                      "environmental_impact_current" => 83,
                      "environmental_impact_potential" => 84,
                      "energy_consumption_current" => 102,
                      "energy_consumption_potential" => 96,
                      "co2_emissions_current" => 1.7,
                      "co2_emissions_potential" => 1.6,
                      "co2_emissions_current_per_floor_area" => 19,
                      "lighting_cost_current" => 83,
                      "lighting_cost_potential" => 55,
                      "heating_cost_current" => 277,
                      "heating_cost_potential" => 281,
                      "hot_water_cost_current" => 114,
                      "hot_water_cost_potential" => 114,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 1,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => 24,
                          "indicative_cost" => "£25",
                          "energy_performance_rating" => 81,
                          "environmental_impact_rating" => 84 },
                        { "sequence" => 2,
                          "improvement_category" => 3,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "typical_saving" => 31,
                          "indicative_cost" => "£4,000 - £6,000",
                          "energy_performance_rating" => 83,
                          "environmental_impact_rating" => 86 },
                        { "sequence" => 3,
                          "improvement_category" => 3,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => 241,
                          "indicative_cost" => "£9,000 - £14,000",
                          "energy_performance_rating" => 92,
                          "environmental_impact_rating" => 95 }],
                      "data_type" => 2,
                      "schema_version" => "LIG-NI-17.0",
                      "built_form" => 4,
                      "living_area" => 20.82,
                      "orientation" => 1,
                      "conservatory_type" => 1,
                      "is_in_smoke_control_area" => "unknown",
                      "sap_opening_types" =>
                       [{ "name" => "front", "data_source" => 2, "type" => 1, "glazing_type" => 1, "u_value" => 1.5 },
                        { "name" => "back", "data_source" => 2, "type" => 2, "glazing_type" => 5, "u_value" => 1.5 },
                        { "name" => "front", "data_source" => 2, "type" => 4, "glazing_type" => 5, "solar_transmittance" => 0.72, "frame_factor" => 0.7, "u_value" => 1.5 },
                        { "name" => "back", "data_source" => 2, "type" => 4, "glazing_type" => 5, "solar_transmittance" => 0.72, "frame_factor" => 0.7, "u_value" => 1.5 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2012,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "front", "type" => "front", "location" => "Walls (1)", "orientation" => 0, "width" => 1.89, "height" => 1 },
                            { "name" => "back", "type" => "back", "location" => "Walls (1)", "orientation" => 0, "width" => 1.89, "height" => 1 },
                            { "name" => "front", "type" => "front", "location" => "Walls (1)", "orientation" => 1, "width" => 5.99, "height" => 1 },
                            { "name" => "back", "type" => "back", "location" => "Walls (1)", "orientation" => 5, "width" => 6.68, "height" => 1 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0, "floor_type" => 3, "total_floor_area" => 43.08, "storey_height" => 2.45, "heat_loss_area" => 0, "u_value" => 0 },
                            { "storey" => 1, "floor_type" => 3, "total_floor_area" => 44.31, "storey_height" => 2.62, "heat_loss_area" => 0, "u_value" => 0 }],
                          "sap_roofs" => [{ "name" => "Roof (1)", "description" => "300 attic", "roof_type" => 2, "total_roof_area" => 44.31, "u_value" => 0.14 }],
                          "sap_walls" => [{ "name" => "Walls (1)", "description" => "trad", "wall_type" => 2, "total_wall_area" => 77.4529, "u_value" => 0.3, "is_curtain_walling" => "false" }],
                          "sap_thermal_bridges" => { "thermal_bridge_code" => 4, "user_defined_y_value" => 0.08, "calculation_reference" => "2006 regulations" },
                          "thermal_mass_parameter" => 250 }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 3,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 4.59,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "boiler_index_number" => 16_093,
                             "main_fuel_type" => 1,
                             "main_heating_control" => 2106,
                             "heat_emitter_type" => 1,
                             "main_heating_flue_type" => 2,
                             "is_flue_fan_present" => "true",
                             "is_central_heating_pump_in_heated_space" => "true",
                             "is_interlocked_system" => "true",
                             "has_delayed_start_thermostat" => "false",
                             "load_or_weather_compensation" => 0 }],
                         "secondary_heating_category" => 1,
                         "has_fixed_air_conditioning" => "false",
                         "water_heating_code" => 901,
                         "water_fuel_type" => 1,
                         "has_hot_water_cylinder" => "false",
                         "thermal_store" => 1,
                         "has_solar_panel" => "false" },
                      "sap_energy_source" =>
                       { "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "fixed_lighting_outlets_count" => 10,
                         "low_energy_fixed_lighting_outlets_count" => 5,
                         "low_energy_fixed_lighting_outlets_percentage" => 50,
                         "electricity_tariff" => 1 } }

      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-NI-17.2",
                              assessment_id: "5555-4444-3333-2222-1111")).to eq(expectation)
    end
  end
end
