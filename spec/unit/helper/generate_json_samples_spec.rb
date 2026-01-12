describe Helper::GenerateJsonSamples do
  describe "#parse_assessment" do
    let(:expected_json) do
      { "uprn" => 12_457,
        "roofs" => [{ "description" => "Pitched, 25 mm loft insulation", "energy_efficiency_rating" => 2, "environmental_efficiency_rating" => 2 }, { "description" => "Pitched, 250 mm loft insulation", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
        "walls" => [{ "description" => "Solid brick, as built, no insulation (assumed)", "energy_efficiency_rating" => 1, "environmental_efficiency_rating" => 1 }, { "description" => "Cavity wall, as built, insulated (assumed)", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
        "floors" => [{ "description" => "Suspended, no insulation (assumed)", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 }, { "description" => "Solid, insulated (assumed)", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 }],
        "status" => "entered",
        "tenure" => 1,
        "window" => { "description" => "Fully double glazed", "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 3 },
        "addendum" => { "stone_walls" => "true", "system_build" => "true", "addendum_numbers" => [1, 8] },
        "lighting" => { "description" => "Low energy lighting in 50% of fixed outlets", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 },
        "postcode" => "A0 0AA",
        "hot_water" => { "description" => "From main system", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 },
        "post_town" => "Whitbury",
        "built_form" => 2,
        "door_count" => 2,
        "glazed_area" => 1,
        "region_code" => 1,
        "report_type" => 2,
        "sap_heating" => { "cylinder_size" => 1, "water_heating_code" => 901, "water_heating_fuel" => 26, "instantaneous_wwhrs" => { "rooms_with_bath_and_or_shower" => 1, "rooms_with_mixer_shower_no_bath" => 0, "rooms_with_bath_and_mixer_shower" => 0 }, "secondary_fuel_type" => 25, "main_heating_details" => [{ "has_fghrs" => "N", "main_fuel_type" => 26, "boiler_flue_type" => 2, "fan_flue_present" => "N", "heat_emitter_type" => 1, "emitter_temperature" => 0, "main_heating_number" => 1, "main_heating_control" => 2106, "main_heating_category" => 2, "main_heating_fraction" => 1, "sap_main_heating_code" => 101, "central_heating_pump_age" => 0, "main_heating_data_source" => 1, "main_heating_index_number" => 17_507 }], "immersion_heating_type" => "NA", "has_fixed_air_conditioning" => "false" },
        "sap_version" => 9.8,
        "sap_windows" => [{ "orientation" => 1, "window_area" => 200.1, "window_type" => 2, "glazing_type" => 1, "window_location" => 0 }, { "orientation" => 2, "window_area" => 180.2, "window_type" => 1, "glazing_type" => 2, "window_location" => 1 }],
        "schema_type" => "RdSAP-Schema-20.0.0",
        "country_code" => "EAW",
        "main_heating" => [{ "description" => "Boiler and radiators, anthracite", "energy_efficiency_rating" => 3, "environmental_efficiency_rating" => 1 }, { "description" => "Boiler and radiators, mains gas", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }],
        "dwelling_type" => "Mid-terrace house",
        "language_code" => 1,
        "property_type" => 0,
        "address_line_1" => "1 Some Street",
        "assessment_type" => "RdSAP",
        "completion_date" => "2020-05-04",
        "inspection_date" => "2020-05-04",
        "extensions_count" => 0,
        "measurement_type" => 1,
        "sap_flat_details" => { "level" => 1, "top_storey" => "N", "storey_count" => 3, "flat_location" => 1, "heat_loss_corridor" => 2, "unheated_corridor_length" => 10 },
        "total_floor_area" => 55,
        "transaction_type" => 1,
        "conservatory_type" => 1,
        "heated_room_count" => 5,
        "registration_date" => "2020-05-04",
        "sap_energy_source" => { "mains_gas" => "Y", "meter_type" => 2, "photovoltaic_supply" => { "none_or_no_details" => { "pv_connection" => 0, "percent_roof_area" => 50 } }, "wind_turbines_count" => 0, "wind_turbines_terrain_type" => 2 },
        "secondary_heating" => { "description" => "Room heaters, electric", "energy_efficiency_rating" => 0, "environmental_efficiency_rating" => 0 },
        "lzc_energy_sources" => [11],
        "sap_building_parts" => [{ "identifier" => "Main Dwelling", "wall_dry_lined" => "N", "floor_heat_loss" => 7, "sap_room_in_roof" => { "floor_area" => 100, "insulation" => "AB", "roof_room_connected" => "N", "construction_age_band" => "B" }, "roof_construction" => 4, "wall_construction" => 4, "building_part_number" => 1, "sap_floor_dimensions" => [{ "floor" => 0, "room_height" => { "value" => 2.45, "quantity" => "metres" }, "floor_insulation" => 1, "total_floor_area" => { "value" => 45.82, "quantity" => "square metres" }, "party_wall_length" => { "value" => 7.9, "quantity" => "metres" }, "floor_construction" => 1, "heat_loss_perimeter" => { "value" => 19.5, "quantity" => "metres" } }, { "floor" => 1, "room_height" => { "value" => 2.59, "quantity" => "metres" }, "total_floor_area" => { "value" => 45.82, "quantity" => "square metres" }, "party_wall_length" => { "value" => 7.9, "quantity" => "metres" }, "heat_loss_perimeter" => { "value" => 19.5, "quantity" => "metres" } }], "wall_insulation_type" => 2, "construction_age_band" => "K", "party_wall_construction" => 0, "wall_thickness_measured" => "N", "roof_insulation_location" => 2, "roof_insulation_thickness" => "200mm", "wall_insulation_thickness" => "NI", "floor_insulation_thickness" => "NI" }],
        "low_energy_lighting" => 100,
        "solar_water_heating" => "N",
        "habitable_room_count" => 5,
        "heating_cost_current" => 365.98,
        "insulated_door_count" => 2,
        "co2_emissions_current" => 2.4,
        "energy_rating_average" => 60,
        "energy_rating_current" => 50,
        "lighting_cost_current" => 123.45,
        "main_heating_controls" => [{ "description" => "Programmer, room thermostat and TRVs", "energy_efficiency_rating" => 4, "environmental_efficiency_rating" => 4 }, { "description" => "Time and temperature zone control", "energy_efficiency_rating" => 5, "environmental_efficiency_rating" => 5 }],
        "multiple_glazing_type" => 2,
        "open_fireplaces_count" => 0,
        "heating_cost_potential" => 250.34,
        "hot_water_cost_current" => 200.4,
        "insulated_door_u_value" => 3,
        "mechanical_ventilation" => 0,
        "percent_draughtproofed" => 100,
        "suggested_improvements" => [{ "sequence" => 1, "typical_saving" => 360, "indicative_cost" => "£100 - £350", "improvement_type" => "Z3", "improvement_details" => { "improvement_number" => 5 }, "improvement_category" => 6, "energy_performance_rating" => 50, "environmental_impact_rating" => 50 }, { "sequence" => 2, "typical_saving" => 99, "indicative_cost" => 2000, "improvement_type" => "Z2", "improvement_details" => { "improvement_number" => 1 }, "improvement_category" => 2, "energy_performance_rating" => 60, "environmental_impact_rating" => 64 }, { "sequence" => 3, "typical_saving" => 99, "indicative_cost" => 1000, "improvement_type" => "Z2", "improvement_details" => { "improvement_texts" => { "improvement_summary" => "An improvement summary", "improvement_description" => "An improvement desc" } }, "improvement_category" => 2, "energy_performance_rating" => 60, "environmental_impact_rating" => 64 }],
        "co2_emissions_potential" => 1.4,
        "energy_rating_potential" => 72,
        "lighting_cost_potential" => 84.23,
        "schema_version_original" => "SAP-19.0",
        "hot_water_cost_potential" => 180.43,
        "renewable_heat_incentive" => { "water_heating" => 2285, "impact_of_loft_insulation" => -2114, "impact_of_cavity_insulation" => -122, "impact_of_solid_wall_insulation" => -3560, "space_heating_existing_dwelling" => 13_120 },
        "energy_consumption_current" => 230,
        "multiple_glazed_proportion" => 100,
        "calculation_software_version" => "13.05r16",
        "energy_consumption_potential" => 88,
        "environmental_impact_current" => 52,
        "fixed_lighting_outlets_count" => 16,
        "windows_transmission_details" => { "u_value" => 2, "data_source" => 2, "solar_transmittance" => 0.72 },
        "multiple_glazed_proportion_nr" => "NR",
        "current_energy_efficiency_band" => "E",
        "environmental_impact_potential" => 74,
        "potential_energy_efficiency_band" => "C",
        "co2_emissions_current_per_floor_area" => 20,
        "low_energy_fixed_lighting_outlets_count" => 16 }
    end

    it "returns a redacted document with camel case keys" do
      schema_type = "RdSAP-Schema-20.0.0"
      type = "epc"
      xml = Nokogiri.XML Samples.xml(schema_type, type)
      assessment_id = described_class.get_rrn(xml:, type:, schema_type:)
      json = described_class.parse_assessment(xml:, assessment_id:, schema_type:, type:)
      expect(json).to eq expected_json
    end
  end

  describe "#get_sample_files" do
    let(:output_dir) do
      "#{Dir.pwd}/spec/fixtures/samples/"
    end

    let(:sample_files) do
      described_class.get_sample_files
    end

    it "returns all the expected sample files" do
      expect(sample_files.length).to eq 36
    end

    it "files are being generated from the relevant xml samples" do
      expect(sample_files).to include(/\/spec\/fixtures\/samples/)
    end

    %w[cepc cepc-rr dec dec-rr epc rdsap sap].each do |i|
      it "files are being generated from the relevant xml #{i} sample" do
        expect(sample_files).to include a_string_matching(/#{i}/)
      end
    end

    %w[ac-cert redacted dec_exceeds 15 NI].each do |i|
      it "files do not return an anything that contains #{i}" do
        expect(sample_files).not_to include a_string_matching(/#{i}/)
      end
    end
  end
end
