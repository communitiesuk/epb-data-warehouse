RSpec.describe "parsing with an NI RdSAP configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP (NI)" do
    let(:rdsap) do
      Samples.xml("RdSAP-Schema-NI-20.0.0")
    end

    it "parses the document in the expected format" do
      expectation = { "schema_version_original" => "LIG-19.0",
                      "sap_version" => 9.94,
                      "calculation_software_name" => "iQ-Engine",
                      "calculation_software_version" => "v94.0.1.1",
                      "inspection_date" => "2020-09-28",
                      "report_type" => 2,
                      "completion_date" => "2020-09-28",
                      "registration_date" => "2020-09-28",
                      "status" => "entered",
                      "language_code" => 1,
                      "tenure" => 2,
                      "transaction_type" => 8,
                      "property_type" => 2,
                      "scheme_assessor_id" => "SCH555555",
                      "address_line_1" => "34 CENTRAL ROAD",
                      "post_town" => "FABRICATED TOWN",
                      "postcode" => "BT20 1AA",
                      "uprn" => "UPRN-000011112222",
                      "region_code" => 10,
                      "country_code" => "NIR",
                      "lzc_energy_sources" => [11],
                      "walls" =>
                       [{ "description" => { "language" => "1", "value" => "Cavity wall, filled cavity" },
                          "energy_efficiency_rating" => 3,
                          "environmental_efficiency_rating" => 3 }],
                      "roofs" =>
                       [{ "description" => { "language" => "1", "value" => "(another dwelling above)" },
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 }],
                      "floors" =>
                       [{ "description" => { "language" => "1", "value" => "(another dwelling below)" },
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 }],
                      "window" =>
                       { "description" => { "language" => "1", "value" => "Fully double glazed" },
                         "energy_efficiency_rating" => 3,
                         "environmental_efficiency_rating" => 3 },
                      "main_heating" =>
                       [{ "description" => { "language" => "1", "value" => "Electric storage heaters" },
                          "energy_efficiency_rating" => 3,
                          "environmental_efficiency_rating" => 1 }],
                      "main_heating_controls" =>
                       [{ "description" => { "language" => "1", "value" => "Manual charge control" },
                          "energy_efficiency_rating" => 2,
                          "environmental_efficiency_rating" => 2 }],
                      "hot_water" =>
                       { "description" => { "language" => "1", "value" => "Electric immersion, off-peak" },
                         "energy_efficiency_rating" => 3,
                         "environmental_efficiency_rating" => 2 },
                      "lighting" =>
                       { "description" =>
                          { "language" => "1", "value" => "Low energy lighting in all fixed outlets" },
                         "energy_efficiency_rating" => 5,
                         "environmental_efficiency_rating" => 5 },
                      "secondary_heating" =>
                       { "description" =>
                          { "language" => "1", "value" => "Portable electric heaters (assumed)" },
                         "energy_efficiency_rating" => 0,
                         "environmental_efficiency_rating" => 0 },
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => { "language" => "1", "value" => "Mid-floor flat" },
                      "total_floor_area" => 41,
                      "has_fixed_air_conditioning" => "false",
                      "multiple_glazed_proportion" => 100,
                      "energy_rating_average" => 60,
                      "energy_rating_current" => 75,
                      "energy_rating_potential" => 75,
                      "environmental_impact_current" => 61,
                      "environmental_impact_potential" => 61,
                      "energy_consumption_current" => 359,
                      "energy_consumption_potential" => 359,
                      "co2_emissions_current" => 2.5,
                      "co2_emissions_potential" => 2.5,
                      "co2_emissions_current_per_floor_area" => 61,
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 41 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 41 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 325 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 325 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 163 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 163 },
                      "built_form" => 5,
                      "extensions_count" => 0,
                      "multiple_glazing_type" => 3,
                      "glazing_gap" => 12,
                      "pvc_window_frames" => "true",
                      "glazed_area" => 1,
                      "door_count" => 1,
                      "insulated_door_count" => 0,
                      "percent_draughtproofed" => 100,
                      "habitable_room_count" => 3,
                      "heated_room_count" => 3,
                      "fixed_lighting_outlets_count" => 6,
                      "low_energy_fixed_lighting_outlets_count" => 6,
                      "low_energy_lighting" => 100,
                      "measurement_type" => 1,
                      "mechanical_ventilation" => 0,
                      "open_fireplaces_count" => 0,
                      "solar_water_heating" => "N",
                      "conservatory_type" => 1,

                      "sap_flat_details" =>
                       { "level" => 2,
                         "flat_location" => 1,
                         "top_storey" => "N",
                         "heat_loss_corridor" => 2,
                         "unheated_corridor_length" => 1.2 },
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_age_band" => "E",
                          "sap_floor_dimensions" =>
                           [{ "floor" => 0,
                              "heat_loss_perimeter" => { "quantity" => "metres", "value" => 20 },
                              "party_wall_length" => { "quantity" => "metres", "value" => 5.8 },
                              "total_floor_area" => { "quantity" => "square metres", "value" => 41.18 },
                              "room_height" => { "quantity" => "metres", "value" => 2.4 } }],
                          "floor_heat_loss" => 6,
                          "roof_construction" => 3,
                          "roof_insulation_location" => "ND",
                          "roof_insulation_thickness" => "ND",
                          "wall_construction" => 4,
                          "wall_insulation_type" => 2,
                          "wall_thickness_measured" => "Y",
                          "wall_thickness" => 300,
                          "wall_dry_lined" => "N",
                          "wall_insulation_thickness" => "NI",
                          "party_wall_construction" => 0,
                          "sap_alternative_wall" =>
                           { "wall_construction" => 4,
                             "wall_insulation_type" => 4,
                             "wall_area" => 2.88,
                             "wall_thickness_measured" => "N",
                             "wall_insulation_thickness" => "NI",
                             "wall_dry_lined" => "N",
                             "sheltered_wall" => "Y" } }],
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 7,
                             "main_fuel_type" => 29,
                             "main_heating_control" => 2401,
                             "main_heating_data_source" => 2,
                             "sap_main_heating_code" => 401,
                             "heat_emitter_type" => 0,
                             "main_heating_fraction" => 1,
                             "has_fghrs" => "N",
                             "emitter_temperature" => "NA",
                             "mcs_installed_heat_pump" => "false" }],
                         "water_heating_code" => 903,
                         "water_heating_fuel" => 29,
                         "immersion_heating_type" => 1,
                         "cylinder_size" => 2,
                         "cylinder_insulation_type" => 1,
                         "cylinder_insulation_thickness" => 38,
                         "has_fixed_air_conditioning" => "false",
                         "instantaneous_wwhrs" =>
                          { "rooms_with_bath_and_or_shower" => 1,
                            "rooms_with_mixer_shower_no_bath" => 0,
                            "rooms_with_bath_and_mixer_shower" => 0 } },
                      "sap_energy_source" =>
                       { "meter_type" => 3,
                         "mains_gas" => "N",
                         "wind_turbines_count" => 0,
                         "wind_turbines_terrain_type" => 2,
                         "photovoltaic_supply" =>
                          { "none_or_no_details" => { "percent_roof_area" => 0, "pv_connection" => 0 } } } }

      expect(use_case.execute(xml: rdsap,
                              schema_type: "RdSAP-Schema-NI-20.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end
end
