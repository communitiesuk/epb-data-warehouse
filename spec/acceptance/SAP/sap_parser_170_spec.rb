RSpec.describe "the parser and the SAP configuration (17.0)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from SAP" do
    let(:sap) { Samples.xml "SAP-Schema-17.0" }

    it "parses the document in the expected format" do
      expectation = { "schema_version_original" => "LIG-17.0",
                      "sap_version" => 9.92,
                      "sap_data_version" => 9.9,
                      "calculation_software_name" => "Elmhurst Sap 2012 Desktop",
                      "calculation_software_version" => "4.03r03",
                      "inspection_date" => "2015-06-30",
                      "report_type" => 3,
                      "completion_date" => "2015-06-30",
                      "registration_date" => "2015-06-30",
                      "status" => "entered",
                      "language_code" => 1,
                      "tenure" => "ND",
                      "transaction_type" => 6,
                      "seller_commission_report" => "Y",
                      "property_type" => 0,
                      "scheme_assessor_id" => "SCHE030303",
                      "address_line_1" => "2, Place Park",
                      "address_line_2" => "Central District",
                      "post_town" => "POSTTOWN",
                      "postcode" => "PT34 5BG",
                      "uprn" => 5_555_555_555,
                      "region_code" => 6,
                      "country_code" => "ENG",
                      "assessment_date" => "2013-07-08",
                      "walls" =>
                        [{ "description" => "Average thermal transmittance 0.28 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "roofs" =>
                        [{ "description" => "Average thermal transmittance 0.14 W/m²K",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "floors" =>
                        [{ "description" => "Average thermal transmittance 0.19 W/m²K",
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
                        [{ "description" => "Time and temperature zone control",
                           "energy_efficiency_rating" => 5,
                           "environmental_efficiency_rating" => 5 }],
                      "secondary_heating" =>
                        { "description" => "None",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 },
                      "hot_water" =>
                        { "description" => "From main system",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "lighting" =>
                        { "description" => "Low energy lighting in all fixed outlets",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 },
                      "air_tightness" =>
                        { "description" => "Air permeability 4.9 m³/h.m² (as tested)",
                          "energy_efficiency_rating" => 4,
                          "environmental_efficiency_rating" => 4 },
                      "has_fixed_air_conditioning" => "false",
                      "has_hot_water_cylinder" => "true",
                      "has_heated_separate_conservatory" => "false",
                      "dwelling_type" => "Detached house",
                      "total_floor_area" => 139,
                      "multiple_glazed_percentage" => 100,
                      "energy_rating_average" => 60,
                      "energy_rating_current" => 84,
                      "energy_rating_potential" => 92,
                      "environmental_impact_current" => 84,
                      "environmental_impact_potential" => 92,
                      "energy_consumption_current" => 91,
                      "energy_consumption_potential" => 39,
                      "co2_emissions_current" => 2.2,
                      "co2_emissions_potential" => 1.0,
                      "co2_emissions_current_per_floor_area" => 16,
                      "lighting_cost_current" => { "currency" => "GBP", "value" => 73 },
                      "lighting_cost_potential" => { "currency" => "GBP", "value" => 73 },
                      "heating_cost_current" => { "currency" => "GBP", "value" => 378 },
                      "heating_cost_potential" => { "currency" => "GBP", "value" => 379 },
                      "hot_water_cost_current" => { "currency" => "GBP", "value" => 114 },
                      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 62 },
                      "suggested_improvements" =>
                       [{ "sequence" => 1,
                          "improvement_category" => 5,
                          "improvement_type" => "N",
                          "improvement_details" => { "improvement_number" => 19 },
                          "typical_saving" => { "currency" => "GBP", "value" => 52 },
                          "indicative_cost" => "£4,000 - £6,000",
                          "energy_performance_rating" => 85,
                          "environmental_impact_rating" => 86 },
                        { "sequence" => 2,
                          "improvement_category" => 5,
                          "improvement_type" => "U",
                          "improvement_details" => { "improvement_number" => 34 },
                          "typical_saving" => { "currency" => "GBP", "value" => 275 },
                          "indicative_cost" => "£5,000 - £8,000",
                          "energy_performance_rating" => 92,
                          "environmental_impact_rating" => 92 }],
                      "lzc_energy_sources" => [10],
                      "renewable_heat_incentive" => { "rhi_new_dwelling" => { "space_heating" => 5622, "water_heating" => 2279 } },
                      "data_type" => 2,
                      "built_form" => 1,
                      "living_area" => 18.13,
                      "orientation" => 1,
                      "conservatory_type" => 1,
                      "is_in_smoke_control_area" => "unknown",
                      "sap_opening_types" =>
                       [{ "name" => "Opening Type 1", "data_source" => 2, "type" => 4, "glazing_type" => 3, "solar_transmittance" => 0.76, "frame_factor" => 0.7, "u_value" => 1.5 },
                        { "name" => "Opening Type 2", "data_source" => 2, "type" => 5, "glazing_type" => 3, "solar_transmittance" => 0.76, "frame_factor" => 0.7, "u_value" => 1.5 }],
                      "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2013,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => "Opening 1", "type" => "Opening Type 1", "location" => "External Wall 1", "orientation" => 1, "width" => 7.47, "height" => 1 },
                            { "name" => "Opening 2", "type" => "Opening Type 1", "location" => "External Wall 1", "orientation" => 5, "width" => 6.88, "height" => 1 },
                            { "name" => "Opening 3", "type" => "Opening Type 1", "location" => "External Wall 1", "orientation" => 7, "width" => 5.44, "height" => 1 },
                            { "name" => "Opening 4", "type" => "Opening Type 1", "location" => "External Wall 1", "orientation" => 3, "width" => 6.88, "height" => 1 },
                            { "name" => "Opening 5", "type" => "Opening Type 2", "location" => "Roof 1", "orientation" => 7, "pitch" => 35, "width" => 1.77, "height" => 1 },
                            { "name" => "Opening 6", "type" => "Opening Type 2", "location" => "Roof 1", "orientation" => 3, "pitch" => 35, "width" => 0.59, "height" => 1 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0, "description" => "Heat Loss Floor 1", "floor_type" => 2, "total_floor_area" => 69.63, "storey_height" => 2.4, "heat_loss_area" => 69.63, "u_value" => 0.19 },
                            { "storey" => 1, "floor_type" => 3, "total_floor_area" => 69.63, "storey_height" => 2.4, "heat_loss_area" => 0, "u_value" => 0 }],
                          "sap_roofs" =>
                            [{ "name" => "Roof 1",
                               "description" => "External Roof 1",
                               "roof_type" => 2,
                               "total_roof_area" => 69.63,
                               "u_value" => 0.14 }],
                          "sap_walls" =>
                            [{ "name" => "External Wall 1",
                               "description" => "External Wall 1",
                               "wall_type" => 2,
                               "total_wall_area" => 197.76,
                               "u_value" => 0.28,
                               "is_curtain_walling" => "false" }],
                          "sap_thermal_bridges" =>
                           { "thermal_bridge_code" => 5,
                             "thermal_bridges" =>
                              [{ "thermal_bridge_type" => "E5", "length" => 41.2, "psi_value" => 0.32, "psi_value_source" => 4 },
                               { "thermal_bridge_type" => "E6", "length" => 41.2, "psi_value" => 0.14, "psi_value_source" => 4 },
                               { "thermal_bridge_type" => "E16", "length" => 19.2, "psi_value" => 0.18, "psi_value_source" => 4 }] },
                          "thermal_mass_parameter" => 100 }],
                      "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 5,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 1,
                         "air_permeability" => 4.94,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 1 },
                      "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "main_heating_index_number" => 10_321,
                             "emitter_temperature" => 1,
                             "central_heating_pump_age" => 2,
                             "main_fuel_type" => 1,
                             "main_heating_control" => 2110,
                             "heat_emitter_type" => 1,
                             "main_heating_flue_type" => 2,
                             "is_flue_fan_present" => "true",
                             "is_central_heating_pump_in_heated_space" => "true",
                             "is_interlocked_system" => "true",
                             "has_separate_delayed_start" => "false",
                             "load_or_weather_compensation" => 0 }],
                         "secondary_heating_category" => 1,
                         "has_fixed_air_conditioning" => "false",
                         "water_heating_code" => 901,
                         "water_fuel_type" => 1,
                         "has_hot_water_cylinder" => "true",
                         "thermal_store" => 1,
                         "hot_water_store_size" => 180,
                         "hot_water_store_heat_loss_source" => 2,
                         "hot_water_store_heat_loss" => 1.48,
                         "primary_pipework_insulation" => 4,
                         "has_cylinder_thermostat" => "true",
                         "is_cylinder_in_heated_space" => "true",
                         "is_hot_water_separately_timed" => "true" },
                      "sap_energy_source" =>
                       { "wind_turbines_count" => 0,
                         "wind_turbine_terrain_type" => 1,
                         "fixed_lighting_outlets_count" => 20,
                         "low_energy_fixed_lighting_outlets_count" => 20,
                         "low_energy_fixed_lighting_outlets_percentage" => 100,
                         "electricity_tariff" => 1 } }

      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-17.0",
                              assessment_id: "1111-2222-3333-4444-5555")).to eq(expectation)
    end
  end
end
