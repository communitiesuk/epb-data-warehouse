RSpec.describe "the parser and the SAP configuration (for Northern Ireland)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP (SAP NI 16.1)" do
    let(:rdsap) { Samples.xml "SAP-Schema-NI-16.1", "rdsap" }

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.91,
                      "bedf_revision_number" => 326,
                      "calculation_software_name" => "Stroma RdSAP Software",
                      "calculation_software_version" => "1.4.0.0",
                      "inspection_date" => "2012-09-02",
                      "report_type" => 2,
                      "completion_date" => "2012-09-02",
                      "registration_date" => "2012-09-02",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "tenure" => "ND",
                      "transaction_type" => 1,
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "ORIG000001",
                      "address_line_1" => "22 Lane Street",
                      "post_town" => "Posttown",
                      "postcode" => "BT6 3ED",
                      "uprn" => 5_555_555_555,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "lzc_energy_sources" => [9],
                      "walls" =>
                        [
                          { "description" => "Solid brick, as built, no insulation (assumed)", "energy_efficiency_rating" => 1, "environmental_efficiency_rating" => 1 },
                          { "description" => "Cavity wall, as built, insulated (assumed)",
                            "energy_efficiency_rating" => 4,
                            "environmental_efficiency_rating" => 4 },
                        ],
                      "roofs" =>
                        [{ "description" => "Pitched, 150 mm loft insulation",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
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
                          "environmental_efficiency_rating" => 2 },
                      "lighting" =>
                        { "description" => "No low energy lighting",
                          "energy_efficiency_rating" => 1,
                          "environmental_efficiency_rating" => 1 },
                      "secondary_heating" =>
                        { "description" => "Room heaters, coal",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Mid-terrace house",
                      "total_floor_area" => 82,
                      "has_fixed_air_conditioning" => "false",
                      "energy_rating_average" => 57,
                      "energy_rating_current" => 56,
                      "energy_rating_potential" => 69,
                      "environmental_impact_current" => 43,
                      "environmental_impact_potential" => 55,
                      "energy_consumption_current" => 278,
                      "energy_consumption_potential" => 202,
                      "co2_emissions_current" => 5.8,
                      "co2_emissions_potential" => 4.2,
                      "co2_emissions_current_per_floor_area" => 70,
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 91 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 46 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 676 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 557 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 268 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 143 },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 3,
                          "improvement_type" => "Q",
                          "improvement_details" => { "improvement_number" => 7 },
                          "typical_saving" => { "currency" => "GBP", "value" => 67 },
                          "indicative_cost" => "£4,000 - £14,000",
                          "energy_performance_rating" => 73,
                          "environmental_impact_rating" => 63 },
                        { "sequence" => 2,
                          "improvement_category" => 2,
                          "improvement_type" => "W",
                          "improvement_details" => { "improvement_number" => 47 },
                          "typical_saving" => { "currency" => "GBP", "value" => 57 },
                          "indicative_cost" => "£800 - £1,200",
                          "energy_performance_rating" => 66,
                          "environmental_impact_rating" => 52 },
                        { "sequence" => 3,
                          "improvement_category" => 1,
                          "improvement_type" => "C",
                          "improvement_details" => { "improvement_number" => 2 },
                          "typical_saving" => { "currency" => "GBP", "value" => 23 },
                          "indicative_cost" => "£15 - £30",
                          "energy_performance_rating" => 57,
                          "environmental_impact_rating" => 43 },
                        { "sequence" => 4,
                          "improvement_category" => 1,
                          "improvement_type" => "D",
                          "improvement_details" => { "improvement_number" => 10 },
                          "typical_saving" => { "currency" => "GBP", "value" => 18 },
                          "indicative_cost" => "£80 - £120",
                          "energy_performance_rating" => 58,
                          "environmental_impact_rating" => 44 },
                        { "sequence" => 5,
                          "improvement_category" => 1,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => { "currency" => "GBP", "value" => 35 },
                          "indicative_cost" => "£70",
                          "energy_performance_rating" => 59,
                          "environmental_impact_rating" => 45 },
                        { "sequence" => 6,
                          "improvement_category" => 1,
                          "improvement_type" => "F",
                          "improvement_details" => { "improvement_number" => 4 },
                          "typical_saving" => { "currency" => "GBP", "value" => 36 },
                          "indicative_cost" => "£200 - £400",
                          "energy_performance_rating" => 61,
                          "environmental_impact_rating" => 47 },
                        { "sequence" => 7,
                          "improvement_category" => 1,
                          "improvement_type" => "G",
                          "improvement_details" => { "improvement_number" => 14 },
                          "typical_saving" => { "currency" => "GBP", "value" => 54 },
                          "indicative_cost" => "£350 - £450",
                          "energy_performance_rating" => 63,
                          "environmental_impact_rating" => 49 },
                        { "sequence" => 8,
                          "improvement_category" => 2,
                          "improvement_type" => "I",
                          "improvement_details" => { "improvement_number" => 20 },
                          "typical_saving" => { "currency" => "GBP", "value" => 70 },
                          "indicative_cost" => "£2,200 - £3,000",
                          "energy_performance_rating" => 69,
                          "environmental_impact_rating" => 55 },
                        { "sequence" => 9,
                          "improvement_category" => 3,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "typical_saving" => { "currency" => "GBP", "value" => 49 },
                          "indicative_cost" => "£4,000 - £6,000",
                          "energy_performance_rating" => 71,
                          "environmental_impact_rating" => 58 },
                        { "sequence" => 10,
                          "improvement_category" => 3,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => { "currency" => "GBP", "value" => 209 },
                          "indicative_cost" => "£9,000 - £14,000",
                          "energy_performance_rating" => 84,
                          "environmental_impact_rating" => 72 }],
                      "schema_version" => "LIG-16.1",
                      "built_form" => 4,
                      "extensions_count" => 1,
                      "multiple_glazed_proportion" => 100,
                      "multiple_glazing_type" => 1,
                      "glazed_area" => 1,
                      "door_count" => 2,
                      "insulated_door_count" => 0,
                      "percent_draughtproofed" => 50,
                      "habitable_room_count" => 4,
                      "heated_room_count" => 4,
                      "fixed_lighting_outlets_count" => 14,
                      "low_energy_fixed_lighting_outlets_count" => 0,
                      "low_energy_lighting" => 0,
                      "measurement_type" => 1,
                      "mechanical_ventilation" => 0,
                      "open_fireplaces_count" => 1,
                      "solar_water_heating" => "N",
                      "conservatory_type" => 1,
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_age_band" => "A",
                          "wall_thickness_measured" => "Y",
                          "wall_thickness" => 290,
                          "wall_dry_lined" => "N",
                          "wall_construction" => 3,
                          "wall_insulation_type" => 4,
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "150mm",
                          "sap_floor_dimensions" =>
                           [{ "floor" => 0, "floor_construction" => 1, "floor_insulation" => 1, "heat_loss_perimeter" => 5.5, "total_floor_area" => 26, "room_height" => 2.45 },
                            { "floor" => 1, "heat_loss_perimeter" => 5.5, "total_floor_area" => 26, "room_height" => 2.4 }],
                          "floor_heat_loss" => 7 },
                        { "building_part_number" => 2,
                          "identifier" => "Extension 1",
                          "construction_age_band" => "G",
                          "wall_thickness_measured" => "N",
                          "wall_dry_lined" => "N",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 4,
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "150mm",
                          "sap_floor_dimensions" =>
                           [{ "floor" => 0, "floor_construction" => 1, "floor_insulation" => 1, "heat_loss_perimeter" => 14.5, "total_floor_area" => 15, "room_height" => 2.45 },
                            { "floor" => 1, "heat_loss_perimeter" => 14.5, "total_floor_area" => 15, "room_height" => 2.4 }],
                          "floor_heat_loss" => 7 }],
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "boiler_index_number" => 8061,
                             "main_fuel_type" => 28,
                             "main_heating_control" => 2107,
                             "boiler_flue_type" => 1,
                             "fan_flue_present" => "Y",
                             "heat_emitter_type" => 1,
                             "has_fghrs" => "N" }],
                         "water_heating_code" => 901,
                         "water_heating_fuel" => 28,
                         "secondary_heating_type" => 631,
                         "secondary_fuel_type" => 33,
                         "cylinder_size" => 2,
                         "cylinder_insulation_type" => 2,
                         "cylinder_insulation_thickness" => 50,
                         "cylinder_thermostat" => "N",
                         "has_fixed_air_conditioning" => "false",
                         "wwhrs" => { "rooms_with_bath_and_or_shower" => 1, "rooms_with_mixer_shower_no_bath" => 0, "rooms_with_bath_and_mixer_shower" => 0 } },
                      "sap_energy_source" =>
                       { "meter_type" => 2, "main_gas" => "N", "wind_turbines_count" => 0, "wind_turbines_terrain_type" => 2, "photovoltaic_supply" => { "percent_roof_area" => 0 } } }

      actual = use_case.execute(xml: rdsap,
                                schema_type: "SAP-Schema-NI-16.1",
                                assessment_id: "1234-1234-1234-1234-1234")
      expect(actual).to eq expectation
    end
  end

  context "when loading XML from SAP (SAP NI 16.1)" do
    let(:sap) { Samples.xml "SAP-Schema-NI-16.1", "sap" }

    it "parses the document into the expected format" do
      expectation = { "sap_version" => 9.81,
                      "bedf_revision_number" => 326,
                      "calculation_software_name" => "Elmhurst Energy Systems SAP Calculator",
                      "calculation_software_version" => "Version: EES SAP 4.2.4.0, Sep 2012",
                      "inspection_date" => "2012-09-16",
                      "report_type" => 3,
                      "completion_date" => "2012-09-16",
                      "registration_date" => "2012-09-16",
                      "status" => "entered",
                      "language_code" => 1,
                      "restricted_access" => 0,
                      "transaction_type" => 6,
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "SCHE00001",
                      "address_line_1" => "16 Street Lane",
                      "post_town" => "BELFAST",
                      "postcode" => "BT2 2AB",
                      "uprn" => 5_555_555_555,
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "assessment_date" => "2012-10-16",
                      "lzc_energy_sources" => [9],
                      "walls" =>
                        [{ "description" => "Average thermal transmittance 0.29 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "roofs" =>
                        [{ "description" => "Average thermal transmittance 0.16 W/m²K",
                           "energy_efficiency_rating" => 4,
                           "environmental_efficiency_rating" => 4 }],
                      "floors" =>
                        [{ "description" => "Average thermal transmittance 0.19 W/m²K",
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
                        { "description" => "Low energy lighting in 62% of fixed outlets",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "air_tightness" =>
                        { "description" => "Air permeability 3.8 m³/h.m² (as tested)",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "false",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Semi-detached house",
                      "total_floor_area" => 111,
                      "energy_rating_current" => 82,
                      "energy_rating_potential" => 83,
                      "environmental_impact_current" => 76,
                      "environmental_impact_potential" => 77,
                      "energy_consumption_current" => 119,
                      "energy_consumption_potential" => 115,
                      "co2_emissions_current" => 2.8,
                      "co2_emissions_potential" => 2.7,
                      "co2_emissions_current_per_floor_area" => 25,
                      "lighting_cost_current" => 89,
                      "lighting_cost_potential" => 64,
                      "heating_cost_current" => 293,
                      "heating_cost_potential" => 298,
                      "hot_water_cost_current" => 184,
                      "hot_water_cost_potential" => 184,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 1,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => 20,
                          "energy_performance_rating" => 83,
                          "environmental_impact_rating" => 77 },
                        { "sequence" => 2,
                          "improvement_category" => 3,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "typical_saving" => 44,
                          "energy_performance_rating" => 84,
                          "environmental_impact_rating" => 79 },
                        { "sequence" => 3,
                          "improvement_category" => 3,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => 216,
                          "energy_performance_rating" => 93,
                          "environmental_impact_rating" => 87 }],
                      "data_type" => 2,
                      "schema_version" => "LIG-15.0",
                      "built_form" => 2,
                      "living_area" => 25.33,
                      "orientation" => 5,
                      "conservatory_type" => 1,
                      "has_special_feature" => "false",
                      "is_in_smoke_control_area" => "unknown",
                      "sap_opening_types" =>
                       [{ "name" => "Doors (1)", "description" => "Front", "data_source" => 3, "type" => 1, "glazing_type" => 1, "u_value" => 3 },
                        { "name" => "Windows (1)",
                          "description" => "Front",
                          "data_source" => 2,
                          "type" => 4,
                          "glazing_type" => 4,
                          "glazing_gap" => 3,
                          "isargonfilled" => "true",
                          "frame_type" => 2,
                          "solar_transmittance" => 0.72,
                          "frame_factor" => 0.7,
                          "u_value" => 1.5 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2012,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "Front", "type" => "Doors (1)", "location" => "Walls (1)", "orientation" => 0, "width" => 2.05, "height" => 1 },
                            { "name" => "Front", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 5, "width" => 5.26, "height" => 1 },
                            { "name" => "Gable", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 7, "width" => 8.66, "height" => 1 },
                            { "name" => "Rear", "type" => "Windows (1)", "location" => "Walls (1)", "orientation" => 1, "width" => 8.79, "height" => 1 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0, "floor_type" => 2, "total_floor_area" => 61.22, "storey_height" => 2.55, "heat_loss_area" => 61.22, "u_value" => 0.19 },
                            { "storey" => 1, "floor_type" => 3, "total_floor_area" => 49.77, "storey_height" => 2.7, "heat_loss_area" => 0, "u_value" => 0 }],
                          "sap_exposed_roofs" => { "sap_exposed_roof" => { "name" => "Roof (1)", "total_roof_area" => 61.22, "u_value" => 0.16 } },
                          "sap_exposed_walls" => { "sap_exposed_wall" => { "name" => "Walls (1)", "wall_type" => 2, "total_wall_area" => 112.7, "u_value" => 0.29, "is_curtain_walling" => "false" } } }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 0,
                         "fans_vents_count" => 4,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 3.8,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_category" => 2,
                         "main_heating_data_source" => 1,
                         "boiler_index_number" => 15_534,
                         "combi_boiler_type" => 2,
                         "main_fuel_type" => 4,
                         "main_heating_control" => 2110,
                         "water_heating_code" => 901,
                         "water_fuel_type" => 4,
                         "has_hot_water_cylinder" => "false",
                         "heat_emitter_type" => 1,
                         "main_heating_flue_type" => 1,
                         "is_flue_fan_present" => "true",
                         "is_central_heating_pump_in_heated_space" => "false",
                         "is_oil_pump_in_heated_space" => "false",
                         "is_interlocked_system" => "true",
                         "has_delayed_start_thermostat" => "false",
                         "load_or_weather_compensation" => 0,
                         "secondary_heating_category" => 1,
                         "thermal_store" => 1,
                         "has_fixed_air_conditioning" => "false",
                         "hot_water_store_size" => 70,
                         "hot_water_store_heat_loss_source" => 3,
                         "hot_water_store_insulation_type" => 1,
                         "hot_water_store_insulation_thickness" => 25,
                         "has_cylinder_thermostat" => "true",
                         "is_hot_water_separately_timed" => "true",
                         "has_solar_panel" => "false" },
                      "sap_energy_source" =>
                       { "pv_peak_power" => 0,
                         "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "low_energy_fixed_lighting_outlets_percentage" => 62,
                         "electricity_tariff" => 1 } }

      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-NI-16.1",
                              assessment_id: "4321-4321-4321-4321-4321")).to eq expectation
    end
  end
end
