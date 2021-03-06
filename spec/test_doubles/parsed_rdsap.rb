class ParsedRdsap
  def self.get_data
    { "schema_version_original" => "LIG-19.0",
      "sap_version" => 9.94,
      "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
      "calculation_software_version" => "4.05r0005",
      "rrn" => "8570-6826-6530-4969-0202",
      "inspection_date" => "2020-06-01",
      "report_type" => 2,
      "completion_date" => "2020-06-01",
      "registration_date" => "2020-06-01",
      "status" => "entered",
      "language_code" => 1,
      "tenure" => 1,
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "property" =>
        { "address" =>
            { "address_line_1" => "25, Marlborough Place",
              "post_town" => "LONDON",
              "postcode" => "NW8 0PG" },
          "uprn" => 7_435_089_668 },
      "region_code" => 17,
      "country_code" => "EAW",
      "wall" =>
        { "description" => "Cavity wall, as built, insulated (assumed)",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "roof" =>
        { "description" => "Roof room(s), insulated (assumed)",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "floor" =>
        { "description" => "Solid, no insulation (assumed)",
          "energy_efficiency_rating" => 0,
          "environmental_efficiency_rating" => 0 },
      "window" =>
        { "description" => "Fully double glazed",
          "energy_efficiency_rating" => 3,
          "environmental_efficiency_rating" => 3 },
      "main_heating" =>
        { "description" => "Boiler and underfloor heating, mains gas",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "main_heating_controls" =>
        { "description" => "Programmer and at least two room thermostats",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "hot_water" =>
        { "description" => "From main system",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "lighting" =>
        { "description" => "Low energy lighting in 54% of fixed outlets",
          "energy_efficiency_rating" => 4,
          "environmental_efficiency_rating" => 4 },
      "secondary_heating" =>
        { "description" => "None",
          "energy_efficiency_rating" => 0,
          "environmental_efficiency_rating" => 0 },
      "has_hot_water_cylinder" => "true",
      "has_heated_separate_conservatory" => "false",
      "dwelling_type" => "Detached house",
      "total_floor_area" => 404,
      "has_fixed_air_conditioning" => "false",
      "multiple_glazed_proportion" => 100,
      "energy_rating_average" => 60,
      "energy_rating_current" => 74,
      "energy_rating_potential" => 78,
      "environmental_impact_current" => 66,
      "environmental_impact_potential" => 71,
      "energy_consumption_current" => 136,
      "energy_consumption_potential" => 113,
      "co2_emissions_current" => 9.7,
      "co2_emissions_potential" => 8.1,
      "co2_emissions_current_per_floor_area" => 24,
      "lighting_cost_current" => { "currency" => "GBP", "value" => 255 },
      "lighting_cost_potential" => { "currency" => "GBP", "value" => 175 },
      "heating_cost_current" => { "currency" => "GBP", "value" => 1589 },
      "heating_cost_potential" => { "currency" => "GBP", "value" => 1513 },
      "hot_water_cost_current" => { "currency" => "GBP", "value" => 154 },
      "hot_water_cost_potential" => { "currency" => "GBP", "value" => 154 },
      "suggested_improvements" =>
        [{ "sequence" => 1,
           "improvement_category" => 5,
           "green_deal_category" => 1,
           "improvement_type" => "E",
           "improvement_details" => { "improvement_number" => 35 },
           "typical_saving" => { "currency" => "GBP", "value" => 69 },
           "indicative_cost" => 225,
           "energy_performance_rating" => 74,
           "environmental_impact_rating" => 67 },
         { "sequence" => 2,
           "improvement_category" => 5,
           "green_deal_category" => 3,
           "improvement_type" => "G",
           "improvement_details" => { "improvement_number" => 16 },
           "typical_saving" => { "currency" => "GBP", "value" => 86 },
           "indicative_cost" => 450,
           "energy_performance_rating" => 75,
           "environmental_impact_rating" => 68 },
         { "sequence" => 3,
           "improvement_category" => 5,
           "green_deal_category" => 2,
           "improvement_type" => "U",
           "improvement_details" => { "improvement_number" => 34 },
           "typical_saving" => { "currency" => "GBP", "value" => 327 },
           "indicative_cost" => "5,500",
           "energy_performance_rating" => 78,
           "environmental_impact_rating" => 71 }],
      "renewable_heat_incentive" =>
        { "space_heating_existing_dwelling" => 32_363, "water_heating" => 3108 },
      "built_form" => 1,
      "extensions_count" => 2,
      "multiple_glazing_type" => 3,
      "pvc_window_frames" => "false",
      "glazed_area" => 1,
      "door_count" => 0,
      "insulated_door_count" => 0,
      "percent_draughtproofed" => 100,
      "habitable_room_count" => 10,
      "heated_room_count" => 10,
      "fixed_lighting_outlets_count" => 98,
      "low_energy_fixed_lighting_outlets_count" => 53,
      "low_energy_lighting" => 54,
      "measurement_type" => 1,
      "mechanical_ventilation" => 0,
      "open_fireplaces_count" => 0,
      "solar_water_heating" => "N",
      "conservatory_type" => 1,
      "sap_building_parts" =>
        [{ "building_part_number" => 1,
           "identifier" => "Main Dwelling",
           "construction_age_band" => "H",
           "sap_floor_dimensions" =>
             [{ "floor" => 0,
                "floor_construction" => 0,
                "floor_insulation" => 1,
                "heat_loss_perimeter" => { "quantity" => "metres", "value" => 27.09 },
                "party_wall_length" => { "quantity" => "metres", "value" => 0 },
                "total_floor_area" => { "quantity" => "square metres", "value" => 79.94 },
                "room_height" => { "quantity" => "metres", "value" => 2.37 } },
              { "floor" => 1,
                "heat_loss_perimeter" => { "quantity" => "metres", "value" => 35.78 },
                "party_wall_length" => { "quantity" => "metres", "value" => 0 },
                "total_floor_area" => { "quantity" => "square metres", "value" => 79.94 },
                "room_height" => { "quantity" => "metres", "value" => 2.43 } }],
           "floor_insulation_thickness" => "NI",
           "floor_heat_loss" => 7,
           "roof_construction" => 5,
           "roof_insulation_location" => 4,
           "roof_insulation_thickness" => "ND",
           "wall_construction" => 4,
           "wall_insulation_type" => 4,
           "wall_thickness_measured" => "N",
           "wall_dry_lined" => "N",
           "wall_insulation_thickness" => "NI",
           "party_wall_construction" => "NA",
           "sap_room_in_roof" =>
             { "floor_area" => 79.94,
               "construction_age_band" => "H",
               "insulation" => "AB",
               "roof_room_connected" => "N" } },
         { "building_part_number" => 2,
           "identifier" => "Extension 1",
           "construction_age_band" => "H",
           "sap_floor_dimensions" =>
             { "sap_floor_dimension" =>
                 { "floor" => 0,
                   "floor_construction" => 0,
                   "floor_insulation" => 1,
                   "heat_loss_perimeter" => { "quantity" => "metres", "value" => 28.19 },
                   "party_wall_length" => { "quantity" => "metres", "value" => 0 },
                   "total_floor_area" => { "quantity" => "square metres", "value" => 74.25 },
                   "room_height" => { "quantity" => "metres", "value" => 2.37 } } },
           "floor_insulation_thickness" => "NI",
           "floor_heat_loss" => 7,
           "roof_construction" => 5,
           "roof_insulation_location" => 4,
           "roof_insulation_thickness" => "ND",
           "wall_construction" => 4,
           "wall_insulation_type" => 4,
           "wall_thickness_measured" => "N",
           "wall_dry_lined" => "N",
           "wall_insulation_thickness" => "NI",
           "party_wall_construction" => "NA",
           "sap_room_in_roof" =>
             { "floor_area" => 74.25,
               "construction_age_band" => "H",
               "insulation" => "AB",
               "roof_room_connected" => "N" } },
         { "building_part_number" => 3,
           "identifier" => "Extension 2",
           "construction_age_band" => "H",
           "sap_floor_dimensions" =>
             { "sap_floor_dimension" =>
                 { "floor" => 0,
                   "floor_construction" => 0,
                   "floor_insulation" => 1,
                   "heat_loss_perimeter" => { "quantity" => "metres", "value" => 3.58 },
                   "party_wall_length" => { "quantity" => "metres", "value" => 0 },
                   "total_floor_area" => { "quantity" => "square metres", "value" => 15.55 },
                   "room_height" => { "quantity" => "metres", "value" => 2.37 } } },
           "floor_insulation_thickness" => "NI",
           "floor_heat_loss" => 7,
           "roof_construction" => 1,
           "roof_insulation_location" => 6,
           "flat_roof_insulation_thickness" => "AB",
           "wall_construction" => 4,
           "wall_insulation_type" => 4,
           "wall_thickness_measured" => "N",
           "wall_dry_lined" => "N",
           "wall_insulation_thickness" => "NI",
           "party_wall_construction" => "NA" }],
      "sap_heating" =>
        { "main_heating_details" =>
            { "main_heating" =>
                { "main_heating_number" => 1,
                  "main_heating_category" => 2,
                  "main_fuel_type" => 26,
                  "main_heating_control" => 2105,
                  "main_heating_data_source" => 2,
                  "sap_main_heating_code" => 102,
                  "boiler_flue_type" => 2,
                  "fan_flue_present" => "N",
                  "heat_emitter_type" => 2,
                  "main_heating_fraction" => 1,
                  "has_fghrs" => "N",
                  "emitter_temperature" => 0,
                  "central_heating_pump_age" => 0 } },
          "water_heating_code" => 901,
          "water_heating_fuel" => 26,
          "immersion_heating_type" => "NA",
          "cylinder_size" => 4,
          "cylinder_insulation_type" => 1,
          "cylinder_insulation_thickness" => 50,
          "cylinder_thermostat" => "Y",
          "has_fixed_air_conditioning" => "false",
          "instantaneous_wwhrs" =>
            { "rooms_with_bath_and_or_shower" => 5,
              "rooms_with_mixer_shower_no_bath" => 3,
              "rooms_with_bath_and_mixer_shower" => 2 } },
      "sap_energy_source" =>
        { "meter_type" => 3,
          "mains_gas" => "Y",
          "wind_turbines_count" => 0,
          "wind_turbines_terrain_type" => 2,
          "photovoltaic_supply" =>
            { "none_or_no_details" => { "percent_roof_area" => 0, "pv_connection" => 0 } } } }
  end
end
