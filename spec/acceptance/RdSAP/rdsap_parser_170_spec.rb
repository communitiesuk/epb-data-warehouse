RSpec.describe "the parser and the RdSAP configuration for 17.0" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from RdSAP" do
    let(:rdsap) { Samples.xml "RdSAP-Schema-17.0" }

    it "parses the document in the expected format" do
      expectation = { "calculation_software_name" => "NHER EPC Online",
                      "calculation_software_version" => "9.0.0",
                      "schema_version_original" => "LIG-17.0",
                      "sap_version" => 9.92,
                      "walls" =>
                       [{ "description" => { "language" => "1", "value" => "System built, with internal insulation" }, "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
                      "roofs" => [{ "description" => { "language" => "1", "value" => "(another dwelling above)" }, "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 }],
                      "floors" => [{ "description" => { "language" => "1", "value" => "(another dwelling below)" }, "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 }],
                      "window" => { "description" => { "language" => "1", "value" => "Fully double glazed" }, "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 3 },
                      "main-heating" => [{ "description" => { "language" => "1", "value" => "Electric storage heaters" }, "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 1 }],
                      "main_heating_controls" =>
                       [{ "description" => { "language" => "1", "value" => "Manual charge control" }, "energy_efficiency_rating" => 2, "environmental_efficiency_rating" => 2 }],
                      "hot_water" => { "description" => { "language" => "1", "value" => "Electric immersion, off-peak" }, "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 2 },
                      "lighting" =>
                       { "description" => { "language" => "1", "value" => "Low energy lighting in 57% of fixed outlets" },
                         "energy_efficiency_rating" => 4,
                         "environmental_efficiency_rating" => 4 },
                      "secondary_heating" =>
                       { "description" => { "language" => "1", "value" => "Portable electric heaters (assumed)" }, "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 },
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => { "language" => "1", "value" => "Mid-floor flat" },
                      "total_floor_area" => 55,
                      "has_fixed_air_conditioning" => "false",
                      "multiple_glazed_proportion" => 100,
                      "energy_rating_current" => 66,
                      "energy_rating_potential" => 79,
                      "environmental_impact_current" => 48,
                      "environmental_impact_potential" => 66,
                      "energy_consumption_current" => 427,
                      "energy_consumption_potential" => 267,
                      "co2_emissions_current" => 3.9,
                      "co2_emissions_current_per_floor_area" => 72,
                      "co2_emissions_potential" => 2.5,
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 61 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 42 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 214 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 216 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 396 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 154 },
                      "energy_rating_average" => 60,
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 5,
                          "improvement_type" => "C",
                          "improvement_details" => { "improvement_number" => 1 },
                          "typical_saving" => { "currency" => "GBP", "value" => 158 },
                          "indicative_cost" => "£15 - £30",
                          "energy_performance_rating" => 74,
                          "environmental_impact_rating" => 60 },
                        { "sequence" => 2,
                          "improvement_category" => 5,
                          "improvement_type" => "E",
                          "improvement_details" => { "improvement_number" => 35 },
                          "typical_saving" => { "currency" => "GBP", "value" => 14 },
                          "indicative_cost" => "£15",
                          "energy_performance_rating" => 74,
                          "environmental_impact_rating" => 60 },
                        { "sequence" => 3,
                          "improvement_category" => 5,
                          "improvement_type" => "L2",
                          "improvement_details" => { "improvement_number" => 60 },
                          "typical_saving" => { "currency" => "GBP", "value" => 64 },
                          "indicative_cost" => "£1,200 - £1,800",
                          "energy_performance_rating" => 78,
                          "environmental_impact_rating" => 64 },
                        { "sequence" => 4,
                          "improvement_category" => 5,
                          "improvement_type" => "X",
                          "improvement_details" => { "improvement_number" => 48 },
                          "typical_saving" => { "currency" => "GBP", "value" => 22 },
                          "indicative_cost" => "£1,000",
                          "energy_performance_rating" => 79,
                          "environmental_impact_rating" => 66 }],
                      "lzc_energy_sources" => [11],
                      "alternative_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 6,
                          "improvement_type" => "J2",
                          "improvement_details" => { "improvement_number" => 54 },
                          "typical_saving" => { "currency" => "GBP", "value" => 141 },
                          "energy_performance_rating" => 81,
                          "environmental_impact_rating" => 96 },
                        { "sequence" => 2,
                          "improvement_category" => 6,
                          "improvement_type" => "Z1",
                          "improvement_details" => { "improvement_number" => 51 },
                          "typical_saving" => { "currency" => "GBP", "value" => 118 },
                          "energy_performance_rating" => 80,
                          "environmental_impact_rating" => 83 }],
                      "renewable_heat_incentive" => { "space_heating_existing_dwelling" => 2415, "water_heating" => 4818 },
                      "property_type" => 2,
                      "built_form" => 2,
                      "multiple_glazing_type" => 3,
                      "pvc_window_frames" => "true",
                      "glazing_gap" => "16+",
                      "extensions_count" => 0,
                      "glazed_area" => 1,
                      "door_count" => 2,
                      "insulated_door_count" => 0,
                      "percent_draughtproofed" => 100,
                      "habitable_room_count" => 3,
                      "heated_room_count" => 1,
                      "fixed_lighting_outlets_count" => 7,
                      "low_energy_fixed_lighting_outlets_count" => 4,
                      "measurement_type" => 1,
                      "mechanical_ventilation" => 0,
                      "open_fireplaces_count" => 0,
                      "solar_water_heating" => "N",
                      "conservatory_type" => 1,
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "construction_age_band" => "D",
                          "wall_construction" => 8,
                          "wall_insulation_type" => 3,
                          "wall_insulation_thickness" => "50mm",
                          "wall_thickness_measured" => "Y",
                          "wall_thickness" => 240,
                          "party_wall_construction" => 0,
                          "roof_construction" => 3,
                          "floor_heat_loss" => 6,
                          "sap_floor_dimensions" =>
                           [{ "floor" => 0,
                              "heat_loss_perimeter" => { "quantity" => "metres", "value" => 23.3 },
                              "total_floor_area" => { "quantity" => "square metres", "value" => 54.6 },
                              "room_height" => { "quantity" => "metres", "value" => 2.4 },
                              "party_wall_length" => { "quantity" => "metres", "value" => 7.3 } }],
                          "identifier" => "Main Dwelling",
                          "roof_insulation_location" => "ND",
                          "roof_insulation_thickness" => "ND",
                          "wall_dry_lined" => "N" }],
                      "sap_flat_details" => { "level" => 2, "flat_location" => 1, "heat_loss_corridor" => 0, "top_storey" => "N" },
                      "sap_heating" =>
                       { "water_heating_code" => 903,
                         "water_heating_fuel" => 29,
                         "immersion_heating_type" => 1,
                         "cylinder_size" => 2,
                         "cylinder_insulation_type" => 0,
                         "has_fixed_air_conditioning" => "false",
                         "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_fraction" => 1,
                             "main_heating_category" => 7,
                             "main_fuel_type" => 29,
                             "main_heating_control" => 2401,
                             "main_heating_data_source" => 2,
                             "sap_main_heating_code" => 402,
                             "has_fghrs" => "N",
                             "emitter_temperature" => "NA",
                             "heat_emitter_type" => 0 }],
                         "instantaneous_wwhrs" => {
                           "rooms_with_bath_and_or_shower" => 1,
                           "rooms_with_mixer_shower_no_bath" => 0,
                           "rooms_with_bath_and_mixer_shower" => 0,
                         } },
                      "sap_energy_source" =>
                       { "wind_turbines_count" => 0,
                         "wind_turbines_terrain_type" => 2,
                         "meter_type" => 1,
                         "mains_gas" => "N",
                         "photovoltaic_supply" => { "none_or_no_details" => { "percent_roof_area" => 0, "pv_connection" => 0 } } },
                      "low_energy_lighting" => 57,
                      "inspection_date" => "2016-01-12",
                      "report_type" => 2,
                      "completion_date" => "2016-01-12",
                      "registration_date" => "2016-01-12",
                      "status" => "entered",
                      "language_code" => 1,
                      "tenure" => 2,
                      "transaction_type" => 8,
                      "scheme_assessor_id" => "SCHE030303",
                      "address_line_1" => "42, Moria Mines Lane",
                      "post_town" => "POSTTOWN",
                      "postcode" => "PT5 4RZ",
                      "uprn" => 4_444_444_444,
                      "region_code" => 3,
                      "country_code" => "EAW" }

      expect(use_case.execute(xml: rdsap,
                              schema_type: "RdSAP-Schema-17.0",
                              assessment_id: "6666-5555-4444-3333-2222")).to eq expectation
    end
  end
end
