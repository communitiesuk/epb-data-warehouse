RSpec.describe "the parser and the SAP configuration (for Northern Ireland)" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from SAP (NI)" do
    let(:sap) do
      Samples.xml "SAP-Schema-NI-18.0.0"
    end

    it "parses the document into the expected format" do
      expectation = {
        "sap_version" => 9.9,
        "hashed_assessment_id" => "4af9d2c31cf53e72ef6f59d3f59a1bfc500ebc2b1027bc5ca47361435d988e1a",
        "bedf_revision_number" => 465,
        "calculation_software_name" => "Stroma FSAP",
        "calculation_software_version" => "Version: 1.5.1.2",
        "inspection_date" => "2020-09-12",
        "report_type" => 3,
        "completion_date" => "2020-09-25",
        "registration_date" => "2020-09-25",
        "status" => "entered",
        "language_code" => 1,
        "restricted_access" => 0,
        "transaction_type" => 6,
        "tenure" => "ND",
        "seller_commission_report" => "Y",
        "property_type" => 2,
        "scheme_assessor_id" => "SCH0000111",
        "address_line_1" => "999 Letsbe Avenue",
        "address_line_2" => "Anydistrict",
        "post_town" => "BELFAST",
        "postcode" => "BT1 1AA",
        "uprn" => "UPRN-000122223333",
        "region_code" => 10,
        "country_code" => "NIR",
        "assessment_date" => "2020-09-12",
        "walls" =>
                       [{ "description" => "Average thermal transmittance 0.21 W/m²K",
                          "energy_efficiency_rating" => 5,
                          "environmental_efficiency_rating" => 5 }],
        "roofs" =>
                       [{ "description" => "(other premises above)",
                          "energy_efficiency_rating" => 0,
                          "environmental_efficiency_rating" => 0 }],
        "floors" =>
                       [{ "description" => "Average thermal transmittance 0.13 W/m²K",
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
                       [{ "description" =>
                           "Time and temperature zone control by suitable arrangement of plumbing and electrical services",
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
                       { "description" => "(not tested)",
                         "energy_efficiency_rating" => 0,
                         "environmental_efficiency_rating" => 0 },
        "lzc_energy_sources" => [11, 9],
        "has_fixed_air_conditioning" => "false",
        "has_hot_water_cylinder" => "false",
        "has_heated_separate_conservatory" => "false",
        "dwelling_type" => "Mid-floor flat",
        "total_floor_area" => 90,
        "energy_rating_average" => 60,
        "energy_rating_typical_newbuild" => 81,
        "energy_rating_current" => 80,
        "energy_rating_potential" => 80,
        "environmental_impact_current" => 82,
        "environmental_impact_potential" => 82,
        "energy_consumption_current" => 104,
        "energy_consumption_potential" => 104,
        "co2_emissions_current" => 1.8,
        "co2_emissions_potential" => 1.8,
        "co2_emissions_current_per_floor_area" => 20,
        "lighting_cost_current" => { "currency" => "GBP", "value" => 71 },
        "lighting_cost_potential" => { "currency" => "GBP", "value" => 71 },
        "heating_cost_current" => { "currency" => "GBP", "value" => 354 },
        "heating_cost_potential" => { "currency" => "GBP", "value" => 354 },
        "hot_water_cost_current" => { "currency" => "GBP", "value" => 79 },
        "hot_water_cost_potential" => { "currency" => "GBP", "value" => 79 },
        "data_type" => 2,
        "schema_version" => "LIG-NI-17.0",
        "living_area" => 30.81,
        "orientation" => 1,
        "conservatory_type" => 1,
        "is_in_smoke_control_area" => "unknown",
        "sap_flat_details" => { "level" => 2 },
        "sap_opening_types" =>
                       [{ "name" => "Door (1)",
                          "description" => "Data from Manufacturer",
                          "data_source" => 2,
                          "type" => 1,
                          "glazing_type" => 1,
                          "u_value" => 1.5 },
                        { "name" => "Windows (1)",
                          "description" => "BFRC data",
                          "data_source" => 4,
                          "type" => 4,
                          "glazing_type" => 6,
                          "solar_transmittance" => 0.43,
                          "u_value" => 1.4 }],
        "sap_building_parts" =>
                       [{ "building_part_number" => 1,
                          "identifier" => "Main Dwelling",
                          "construction_year" => 2020,
                          "overshading" => 2,
                          "sap_openings" =>
                           [{ "name" => 2,
                              "type" => "Door (1)",
                              "location" => "Communal wall",
                              "orientation" => 1,
                              "width" => 0,
                              "height" => 0 },
                            { "name" => 3,
                              "type" => "Windows (1)",
                              "location" => "Ex-28",
                              "orientation" => 1,
                              "width" => 0,
                              "height" => 0 },
                            { "name" => 4,
                              "type" => "Windows (1)",
                              "location" => "Ex-28",
                              "orientation" => 8,
                              "width" => 0,
                              "height" => 0 },
                            { "name" => 5,
                              "type" => "Windows (1)",
                              "location" => "Ex-28",
                              "orientation" => 6,
                              "width" => 0,
                              "height" => 0 }],
                          "sap_floor_dimensions" =>
                           [{ "storey" => 0,
                              "floor_type" => 3,
                              "total_floor_area" => 90.45,
                              "storey_height" => 2.5,
                              "heat_loss_area" => 90.45,
                              "u_value" => 0.13,
                              "kappa_value" => 75 }],
                          "sap_roofs" =>
                           [{ "name" => "Exposed Roof",
                              "roof_type" => 2,
                              "total_roof_area" => 0,
                              "u_value" => 0,
                              "kappa_value" => 0 },
                            { "name" => "Party ceiling",
                              "roof_type" => 4,
                              "total_roof_area" => 90.45,
                              "u_value" => 0,
                              "kappa_value" => 30 }],
                          "sap_walls" =>
                           [{ "name" => "Ex-28",
                              "wall_type" => 2,
                              "total_wall_area" => 57.57,
                              "u_value" => 0.19,
                              "kappa_value" => 14,
                              "is_curtain_walling" => "false" },
                            { "name" => "Ex-col",
                              "wall_type" => 2,
                              "total_wall_area" => 11.84,
                              "u_value" => 0.25,
                              "kappa_value" => 150,
                              "is_curtain_walling" => "false" },
                            { "name" => "Communal wall",
                              "wall_type" => 2,
                              "total_wall_area" => 4.24,
                              "u_value" => 0.24,
                              "kappa_value" => 14,
                              "is_curtain_walling" => "false" },
                            { "name" => "Metal stud",
                              "wall_type" => 5,
                              "total_wall_area" => 173.67,
                              "u_value" => 0,
                              "kappa_value" => 9 },
                            { "name" => "Party wall",
                              "wall_type" => 4,
                              "total_wall_area" => 50.04,
                              "u_value" => 0,
                              "kappa_value" => 70 }],
                          "sap_thermal_bridges" => { "thermal_bridge_code" => 1 } }],
        "sap_ventilation" =>
                       { "open_fireplaces_count" => 0,
                         "open_flues_count" => 0,
                         "extract_fans_count" => 0,
                         "psv_count" => 0,
                         "flueless_gas_fires_count" => 0,
                         "pressure_test" => 3,
                         "air_permeability" => 15,
                         "sheltered_sides_count" => 2,
                         "ventilation_type" => 5,
                         "is_mechanical_vent_approved_installer_scheme" => "true",
                         "mechanical_ventilation_data_source" => 1,
                         "mechanical_vent_system_index_number" => 500_107,
                         "wet_rooms_count" => 3,
                         "mechanical_vent_duct_type" => 2 },
        "sap_heating" =>
                       { "main_heating_details" =>
                          [{ "main_heating_number" => 1,
                             "main_heating_category" => 2,
                             "main_heating_fraction" => 1,
                             "main_heating_data_source" => 1,
                             "boiler_index_number" => 17_929,
                             "main_fuel_type" => 1,
                             "main_heating_control" => 2110,
                             "heat_emitter_type" => 1,
                             "main_heating_flue_type" => 2,
                             "is_flue_fan_present" => "true",
                             "is_central_heating_pump_in_heated_space" => "true",
                             "is_interlocked_system" => "true",
                             "has_delayed_start_thermostat" => "true",
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
                         "wind_turbine_terrain_type" => 2,
                         "fixed_lighting_outlets_count" => 15,
                         "low_energy_fixed_lighting_outlets_count" => 15,
                         "low_energy_fixed_lighting_outlets_percentage" => 100,
                         "electricity_tariff" => 1 },
      }

      expect(use_case.execute(xml: sap,
                              schema_type: "SAP-Schema-NI-18.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end
end
