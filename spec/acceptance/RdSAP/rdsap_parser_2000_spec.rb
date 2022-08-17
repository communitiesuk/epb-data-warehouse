RSpec.describe "the parser and the rdsap configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading xml from RdSap" do
    let(:rdsap) do
      Samples.xml("RdSAP-Schema-20.0.0")
    end

    it "parses the document in the expected format" do
      expectation = { "calculation_software_name" => "SomeSoft RdSAP Calculator",
                      "calculation_software_version" => "13.05r16",
                      "schema_version_original" => "SAP-19.0",
                      "sap_version" => 9.8,
                      "walls" =>
                       [{ "description" => "Solid brick, as built, no insulation (assumed)",
                          "energy_efficiency_rating" => 1,
                          "environmental_efficiency_rating" => 1 },
                        { "description" => "Cavity wall, as built, insulated (assumed)",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 }],
                      "roofs" =>
                       [{ "description" => "Pitched, 25 mm loft insulation",
                          "energy_efficiency_rating" => 2,
                          "environmental_efficiency_rating" => 2 },
                        { "description" => "Pitched, 250 mm loft insulation",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 }],
                      "floors" =>
                       [{ "description" => "Suspended, no insulation (assumed)",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                        { "description" => "Solid, insulated (assumed)",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 }],
                      "window" =>
                       { "description" => "Fully double glazed",
                         "energy_efficiency_rating" => 3,
                         "environmental_efficiency_rating" => 3 },
                      "main-heating" =>
                       [{ "description" => "Boiler and radiators, anthracite",
                          "energy_efficiency_rating" => 3,
                          "environmental_efficiency_rating" => 1 },
                        { "description" => "Boiler and radiators, mains gas",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 }],
                      "main_heating_controls" =>
                       [{ "description" => "Programmer, room thermostat and TRVs",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                        { "description" => "Time and temperature zone control",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
                      "hot_water" =>
                       { "description" => "From main system",
                         "energy_efficiency_rating" => 4,
                         "environmental_efficiency_rating" => 4 },
                      "lighting" =>
                       { "description" => "Low energy lighting in 50% of fixed outlets",
                         "energy_efficiency_rating" => 4,
                         "environmental_efficiency_rating" => 4 },
                      "secondary_heating" =>
                       { "description" => "Room heaters, electric",
                         "energy_efficiency_rating" => 0,
                         "environmental_efficiency_rating" => 0 },
                      "dwelling_type" => "Mid-terrace house",
                      "total_floor_area" => 55,
                      "multiple_glazed_proportion_nr" => "NR",
                      "energy_rating_current" => 50,
                      "energy_rating_potential" => 72,
                      "energy_rating_average" => 60,
                      "environmental_impact_current" => 52,
                      "environmental_impact_potential" => 74,
                      "energy_consumption_current" => 230,
                      "energy_consumption_potential" => 88,
                      "co2_emissions_current" => 2.4,
                      "co2_emissions_current_per_floor_area" => 20,
                      "co2_emissions_potential" => 1.4,
                      "lighting_cost_current" => 123.45,
                      "lighting_cost_potential" => 84.23,
                      "heating_cost_current" => 365.98,
                      "heating_cost_potential" => 250.34,
                      "hot_water_cost_current" => 200.4,
                      "hot_water_cost_potential" => 180.43,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 6,
                          "improvement_type" => "Z3",
                          "typical_saving" => 360,
                          "energy_performance_rating" => 50,
                          "environmental_impact_rating" => 50,
                          "indicative_cost" => "£100 - £350",
                          "improvement_details" => { "improvement_number" => 5 } },
                        { "sequence" => 2,
                          "improvement_category" => 2,
                          "improvement_type" => "Z2",
                          "typical_saving" => 99,
                          "energy_performance_rating" => 60,
                          "environmental_impact_rating" => 64,
                          "indicative_cost" => 2000,
                          "improvement_details" => { "improvement_number" => 1 } },
                        { "sequence" => 3,
                          "improvement_category" => 2,
                          "improvement_type" => "Z2",
                          "typical_saving" => 99,
                          "energy_performance_rating" => 60,
                          "environmental_impact_rating" => 64,
                          "indicative_cost" => 1000,
                          "improvement_details" =>
                           { "improvement_texts" => { "improvement_description" => "Improvement desc" } } }],
                      "lzc_energy_sources" => [11],
                      "renewable_heat_incentive" =>
                       { "space_heating_existing_dwelling" => 13_120,
                         "water_heating" => 2285,
                         "impact_of_loft_insulation" => -2114,
                         "impact_of_cavity_insulation" => -122,
                         "impact_of_solid_wall_insulation" => -3560 },
                      "addendum" =>
                       { "addendum_numbers" => [1, 8], "stone_walls" => "true", "system_build" => "true" },
                      "property_type" => 0,
                      "built_form" => 2,
                      "extensions_count" => 0,
                      "multiple_glazed_proportion" => 100,
                      "multiple_glazing_type" => 2,
                      "glazed_area" => 1,
                      "door_count" => 2,
                      "insulated_door_count" => 2,
                      "insulated_door_u_value" => 3,
                      "windows_transmission_details" =>
                       { "u_value" => 2, "solar_transmittance" => 0.72, "data_source" => 2 },
                      "percent_draughtproofed" => 100,
                      "habitable_room_count" => 5,
                      "heated_room_count" => 5,
                      "fixed_lighting_outlets_count" => 16,
                      "low_energy_fixed_lighting_outlets_count" => 16,
                      "low_energy_lighting" => 100,
                      "measurement_type" => 1,
                      "mechanical_ventilation" => 0,
                      "open_fireplaces_count" => 0,
                      "solar_water_heating" => "N",
                      "conservatory_type" => 1,
                      "sap_flat_details" =>
                       { "flat_location" => 1,
                         "storey_count" => 3,
                         "level" => 1,
                         "top_storey" => "N",
                         "heat_loss_corridor" => 2,
                         "unheated_corridor_length" => 10 },
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_age_band" => "K",
                          "sap_floor_dimensions" =>
                           [{ "floor" => 0,
                              "floor_construction" => 1,
                              "floor_insulation" => 1,
                              "heat_loss_perimeter" => { "quantity" => "metres", "value" => 19.5 },
                              "party_wall_length" => { "quantity" => "metres", "value" => 7.9 },
                              "total_floor_area" => { "quantity" => "square metres", "value" => 45.82 },
                              "room_height" => { "quantity" => "metres", "value" => 2.45 } },
                            { "floor" => 1,
                              "heat_loss_perimeter" => { "quantity" => "metres", "value" => 19.5 },
                              "party_wall_length" => { "quantity" => "metres", "value" => 7.9 },
                              "total_floor_area" => { "quantity" => "square metres", "value" => 45.82 },
                              "room_height" => { "quantity" => "metres", "value" => 2.59 } }],
                          "floor_insulation_thickness" => "NI",
                          "floor_heat_loss" => 7,
                          "roof_construction" => 4,
                          "roof_insulation_location" => 2,
                          "roof_insulation_thickness" => "200mm",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 2,
                          "wall_thickness_measured" => "N",
                          "wall_dry_lined" => "N",
                          "wall_insulation_thickness" => "NI",
                          "party_wall_construction" => 0,
                          "sap_room_in_roof" =>
                           { "floor_area" => 100,
                             "construction_age_band" => "B",
                             "insulation" => "AB",
                             "roof_room_connected" => "N" } }],
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_fuel_type" => 26,
                             "main_heating_control" => 2106,
                             "main_heating_data_source" => 1,
                             "sap_main_heating_code" => 101,
                             "main_heating_index_number" => 17_507,
                             "boiler_flue_type" => 2,
                             "fan_flue_present" => "N",
                             "heat_emitter_type" => 1,
                             "main_heating_fraction" => 1,
                             "has_fghrs" => "N",
                             "emitter_temperature" => 0,
                             "central_heating_pump_age" => 0 }],
                         "water_heating_code" => 901,
                         "water_heating_fuel" => 26,
                         "immersion_heating_type" => "NA",
                         "cylinder_size" => 1,
                         "has_fixed_air_conditioning" => "false",
                         "instantaneous_wwhrs" =>
                          { "rooms_with_bath_and_or_shower" => 1,
                            "rooms_with_mixer_shower_no_bath" => 0,
                            "rooms_with_bath_and_mixer_shower" => 0 },
                         "secondary_fuel_type" => 25 },
                      "sap_energy_source" =>
                       { "meter_type" => 2,
                         "mains_gas" => "Y",
                         "wind_turbines_count" => 0,
                         "wind_turbines_terrain_type" => 2,
                         "photovoltaic_supply" =>
                          { "none_or_no_details" => { "percent_roof_area" => 0, "pv_connection" => 0 } } },
                      "sap_windows" =>
                       [{ "window_location" => 0,
                          "window_area" => 200.1,
                          "glazing_type" => 1,
                          "window_type" => 2,
                          "orientation" => 1 },
                        { "window_location" => 1,
                          "window_area" => 180.2,
                          "glazing_type" => 2,
                          "window_type" => 1,
                          "orientation" => 2 }],
                      "inspection_date" => "2020-05-04",
                      "report_type" => 2,
                      "completion_date" => "2020-05-04",
                      "registration_date" => "2020-05-04",
                      "status" => "entered",
                      "language_code" => 1,
                      "region_code" => 1,
                      "country_code" => "EAW",
                      "transaction_type" => 1,
                      "tenure" => 1,
                      "scheme_assessor_id" => "SPEC000000",
                      "address_line_1" => "1 Some Street",
                      "post_town" => "Whitbury",
                      "postcode" => "A0 0AA",
                      "uprn" => "UPRN-000000000000" }

      expect(use_case.execute(xml: rdsap,
                              schema_type: "RdSAP-Schema-20.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end
end
