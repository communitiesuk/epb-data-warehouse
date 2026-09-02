describe "the parser and the CEPC configuration for schema 3.1" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML from CEPC" do
    let(:cepc) { Samples.xml "CEPC-3.1", "cepc" }

    it "parses the document in the expected format" do
      expectation = { "address_line_1" => "Some Unit",
                      "address_line_2" => "2 Lonely Street",
                      "address_line_3" => "Some Area",
                      "address_line_4" => "Some County",
                      "asset_rating" => 80,
                      "building_complexity" => "Level 3",
                      "calculation_tool" => "Casio fx-39",
                      "existing_stock_benchmark" => 81,
                      "inspection_date" => "2020-05-04",
                      "is_heritage_site" => "N",
                      "issue_date" => "2020-05-14",
                      "language_code" => 1,
                      "new_build_benchmark" => 28,
                      "post_town" => "Whitbury",
                      "postcode" => "SW1A 2AA",
                      "property_type" => "B1 Offices and Workshop businesses",
                      "registration_date" => "2020-05-04",
                      "report_type" => 3,
                      "scheme_assessor_id" => "SPEC000000",
                      "status" => "entered",
                      "summary_of_performance" => { "building_data" => [{ "activities" => [{ "area" => 402.6, "id" => 1005 }], "analysis_type" => "ACTUAL", "area" => 402.6, "area_exterior" => 1058.32, "building_alpha" => 18.3412, "building_w_k" => 411.86, "building_w_m2k" => 0.389164, "global_performance" => { "kwh_m2_anthracite" => 0, "kwh_m2_auxiliary" => 39.0832, "kwh_m2_biogas" => 0, "kwh_m2_biomass" => 0, "kwh_m2_chp" => 0, "kwh_m2_coal" => 0, "kwh_m2_cooling" => 25.3865, "kwh_m2_dhw" => 2.77834, "kwh_m2_displaced" => 6.10442, "kwh_m2_district_heating" => 0, "kwh_m2_dual_fuel" => 0, "kwh_m2_equipment" => 42.185, "kwh_m2_heating" => 41.0355, "kwh_m2_lighting" => 54.0787, "kwh_m2_lpg" => 0, "kwh_m2_natural_gas" => 41.0355, "kwh_m2_oil" => 0, "kwh_m2_pvs" => 3.07665, "kwh_m2_ses" => 0.801605, "kwh_m2_smokeless" => 0, "kwh_m2_supplied" => 121.327, "kwh_m2_waste_heat" => 0, "kwh_m2_wind" => 3.02777 }, "hvac_systems" => [{ "activities" => [{ "area" => 402.6, "id" => 1005 }], "area" => 402.6, "cooling_gen_seer" => 2.5, "cooling_sseer" => 1.963, "fuel_type" => "Natural Gas", "heat_source" => "LTHW boiler", "heating_gen_seff" => 0.89, "heating_sseff" => 0.827, "kwh_m2_auxiliary" => 39.0832, "kwh_m2_cooling" => 25.3865, "kwh_m2_heating" => 41.0355, "mj_m2_cooling_dem" => 179.401, "mj_m2_heating_dem" => 122.171, "type" => "Fan coil systems" }], "q50_infiltration" => 10, "weather" => "LON" }, { "activities" => [{ "area" => 402.6, "id" => 1005 }], "analysis_type" => "NOTIONAL", "area" => 402.6, "area_exterior" => 1058.32, "building_alpha" => 11.2489, "building_w_k" => 362.524, "building_w_m2k" => 0.342547, "global_performance" => { "kwh_m2_anthracite" => 0, "kwh_m2_auxiliary" => 14.0716, "kwh_m2_biogas" => 0, "kwh_m2_biomass" => 0, "kwh_m2_chp" => 0, "kwh_m2_coal" => 0, "kwh_m2_cooling" => 7.46769, "kwh_m2_dhw" => 3.33761, "kwh_m2_displaced" => 0, "kwh_m2_district_heating" => 0, "kwh_m2_dual_fuel" => 0, "kwh_m2_equipment" => 42.185, "kwh_m2_heating" => 18.1582, "kwh_m2_lighting" => 14.4489, "kwh_m2_lpg" => 0, "kwh_m2_natural_gas" => 18.1582, "kwh_m2_oil" => 3.33761, "kwh_m2_pvs" => 0, "kwh_m2_ses" => 0, "kwh_m2_smokeless" => 0, "kwh_m2_supplied" => 35.9883, "kwh_m2_waste_heat" => 0, "kwh_m2_wind" => 0 }, "hvac_systems" => [{ "activities" => [{ "area" => 402.6, "id" => 1005 }], "area" => 402.6, "cooling_gen_seer" => 0, "cooling_sseer" => 3.6, "fuel_type" => "Natural Gas", "heat_source" => "LTHW boiler", "heating_gen_seff" => 0, "heating_sseff" => 0.819, "kwh_m2_auxiliary" => 14.0716, "kwh_m2_cooling" => 7.46769, "kwh_m2_heating" => 18.1581, "mj_m2_cooling_dem" => 96.7814, "mj_m2_heating_dem" => 53.5375, "type" => "Fan coil systems" }], "q50_infiltration" => 3, "weather" => "LON" }, { "activities" => [{ "area" => 402.6, "id" => 1005 }], "analysis_type" => "REFERENCE", "area" => 402.6, "area_exterior" => 1058.32, "building_alpha" => 10, "building_w_k" => 718.761, "building_w_m2k" => 0.679153, "global_performance" => { "kwh_m2_anthracite" => 0, "kwh_m2_auxiliary" => 2.16062, "kwh_m2_biogas" => 0, "kwh_m2_biomass" => 0, "kwh_m2_chp" => 0, "kwh_m2_coal" => 0, "kwh_m2_cooling" => 25.6538, "kwh_m2_dhw" => 6.41192, "kwh_m2_displaced" => 0, "kwh_m2_district_heating" => 0, "kwh_m2_dual_fuel" => 0, "kwh_m2_equipment" => 42.185, "kwh_m2_heating" => 71.9516, "kwh_m2_lighting" => 45.54, "kwh_m2_lpg" => 0, "kwh_m2_natural_gas" => 78.3634, "kwh_m2_oil" => 0, "kwh_m2_pvs" => 0, "kwh_m2_ses" => 0, "kwh_m2_smokeless" => 0, "kwh_m2_supplied" => 73.3544, "kwh_m2_waste_heat" => 0, "kwh_m2_wind" => 0 }, "hvac_systems" => [{ "activities" => [{ "area" => 402.6, "id" => 1005 }], "area" => 402.6, "cooling_gen_seer" => 0, "cooling_sseer" => 2.25, "fuel_type" => "Natural Gas", "heat_source" => "LTHW boiler", "heating_gen_seff" => 0, "heating_sseff" => 0.73, "kwh_m2_auxiliary" => 2.16062, "kwh_m2_cooling" => 25.6538, "kwh_m2_heating" => 71.9516, "mj_m2_cooling_dem" => 207.795, "mj_m2_heating_dem" => 189.088, "type" => "Fan coil systems" }], "q50_infiltration" => 10, "weather" => "LON" }] },
                      "technical_information" => { "building_environment" => "Air Conditioning", "building_level" => 3, "floor_area" => 403, "main_heating_fuel" => "Natural Gas", "or_availability_date" => "2020-01-04", "other_fuel_description" => "Test", "renewable_sources" => "Renewable sources test", "special_energy_uses" => "Test sp" },
                      "uprn" => 1,
                      "valid_until" => "2026-05-04" }

      actual = use_case.execute(xml: cepc,
                                schema_type: "CEPC-3.1",
                                assessment_id: "0000-0000-0000-0000-0000")
      expect(actual).to eq(expectation)
    end
  end

  context "when loading XML from CEPC-RR" do
    let(:cepc_rr) { Samples.xml "CEPC-3.1", "cepc+rr" }

    it "parses the document in the expected format" do
      expectation = { "address_line_1" => "Some Unit",
                      "address_line_2" => "2 Lonely Street",
                      "address_line_3" => "Some Area",
                      "address_line_4" => "Some County",
                      "calculation_tool" => "CEPC Compute v0.2",
                      "inspection_date" => "2020-05-04",
                      "issue_date" => "2020-05-14",
                      "language_code" => 1,
                      "long_payback" => [{ "co2_impact" => "HIGH", "recommendation" => "Consider installing an air source heat pump.", "recommendation_code" => "EPC-R5" }],
                      "medium_payback" => [{ "co2_impact" => "MEDIUM", "recommendation" => "Add optimum start/stop to the heating system.", "recommendation_code" => "EPC-H7" }],
                      "other_payback" => [{ "co2_impact" => "HIGH", "recommendation" => "Consider installing PV.", "recommendation_code" => "EPC-R4" }],
                      "post_town" => "Fulchester",
                      "postcode" => "SW1A 2AA",
                      "property_type" => "B1 Offices and Workshop businesses",
                      "registration_date" => "2020-05-05",
                      "related_rrn" => "1111-0000-0000-0000-0000",
                      "report_type" => 4,
                      "scheme_assessor_id" => "SPEC000000",
                      "short_payback" => [{ "co2_impact" => "HIGH", "recommendation" => "Consider replacing T8 lamps with retrofit T5 conversion kit.", "recommendation_code" => "ECP-L5" }, { "co2_impact" => "LOW", "recommendation" => "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.", "recommendation_code" => "EPC-L7" }],
                      "status" => "cancelled",
                      "technical_information" => { "building_environment" => "Air Conditioning", "floor_area" => 10 },
                      "uprn" => 0,
                      "valid_until" => "2021-05-03" }

      actual = use_case.execute(xml: cepc_rr,
                                schema_type: "CEPC-3.1",
                                assessment_id: "1111-0000-0000-0000-0001")
      expect(actual).to eq(expectation)
    end
  end

  context "when loading XML from DEC" do
    let(:dec) { Samples.xml "CEPC-3.1", "dec" }

    it "parses the document in the expected format" do
      expectation = { "address_line_1" => "Some Unit",
                      "address_line_2" => "2 Lonely Street",
                      "address_line_3" => "Some Area",
                      "address_line_4" => "Some County",
                      "building_category" => "C1",
                      "calculation_tool" => "DCLG, ORCalc, v3.6.3",
                      "dec_annual_energy_summary" => { "annual_energy_use_electrical" => 1, "annual_energy_use_fuel_thermal" => 1, "renewables_electrical" => 1, "renewables_fuel_thermal" => 1, "typical_electrical_use" => 1, "typical_thermal_use" => 1 },
                      "inspection_date" => "2020-05-04",
                      "is_heritage_site" => "N",
                      "issue_date" => "2020-05-14",
                      "language_code" => 1,
                      "occupier" => "Primary School",
                      "or_assessment_end_date" => "2020-05-01",
                      "or_assessment_start_date" => "2020-05-01",
                      "or_benchmark_data" => { "benchmark_1" => { "benchmark" => "General office", "floor_area" => 10, "occupancy_level" => "level", "total_equivalent" => 3000 } },
                      "or_energy_consumption" => { "electricity" => { "consumption" => 422_480, "end_date" => "2008-07-31", "estimate" => 1, "start_date" => "2007-01-31" }, "gas" => { "consumption" => 310_400, "end_date" => "2007-12-18", "estimate" => 0, "start_date" => "2007-01-18" } },
                      "or_previous_data" => { "asset_rating" => 100 },
                      "post_town" => "Whitbury",
                      "postcode" => "SW1A 2AA",
                      "property_type" => "B1 Offices and Workshop businesses",
                      "registration_date" => "2020-05-04",
                      "related_rrn" => "4192-1535-8427-8844-6702",
                      "report_type" => 1,
                      "scheme_assessor_id" => "SPEC000000",
                      "status" => "entered",
                      "technical_information" => { "building_environment" => "Heating and Natural Ventilation", "floor_area" => 99, "main_heating_fuel" => "Natural Gas", "other_fuel_description" => "other", "special_energy_uses" => "special" },
                      "this_assessment" => { "electricity_co2" => 7, "energy_rating" => 1, "heating_co2" => 3, "nominated_date" => "2020-01-01", "renewables_co2" => 0 },
                      "uprn" => 1,
                      "valid_until" => "2026-05-04",
                      "year1_assessment" => { "electricity_co2" => 10, "energy_rating" => 24, "heating_co2" => 5, "nominated_date" => "2019-01-01", "renewables_co2" => 1 },
                      "year2_assessment" => { "electricity_co2" => 15, "energy_rating" => 40, "heating_co2" => 10, "nominated_date" => "2018-01-01", "renewables_co2" => 2 } }

      actual = use_case.execute(xml: dec,
                                schema_type: "CEPC-3.1",
                                assessment_id: "0000-0000-0000-0000-0000")

      expect(actual).to eq(expectation)
    end
  end

  context "when loading XML from DEC-RR" do
    let(:dec_rr) { Samples.xml "CEPC-3.1", "dec-rr" }

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2020-05-04",
                      "report_type" => 2,
                      "valid_until" => "2028-05-03",
                      "inspection_date" => "2020-05-04",
                      "registration_date" => "2020-05-04",
                      "status" => "entered",
                      "language_code" => 1,
                      "location_description" => "Office",
                      "scheme_assessor_id" => "SPEC000000",
                      "uprn" => 1,
                      "address_line_1" => "Some Unit",
                      "address_line_2" => "2 Lonely Street",
                      "address_line_3" => "Some Area",
                      "address_line_4" => "Some County",
                      "post_town" => "Fulchester",
                      "postcode" => "SW1A 2AA",
                      "occupier" => "Primary School",
                      "property_type" => "University campus",
                      "inspection_type" => "Physical",
                      "calculation_tool" => "DCLG, ORCalc, v3.6.2",
                      "short_payback" => [{ "recommendation_code" => "ECP-L5", "recommendation" => "Consider thinking about maybe possibly getting a solar panel but only one.", "co2_impact" => "MEDIUM" }, { "recommendation_code" => "EPC-L7", "recommendation" => "Consider introducing variable speed drives (VSD) for fans, pumps and compressors.", "co2_impact" => "LOW" }],
                      "medium_payback" => [{ "recommendation_code" => "ECP-C1", "recommendation" => "Engage experts to propose specific measures to reduce hot waterwastage and plan to carry this out.", "co2_impact" => "LOW" }],
                      "long_payback" => [{ "recommendation_code" => "ECP-F4", "recommendation" => "Consider replacing or improving glazing", "co2_impact" => "LOW" }],
                      "other_payback" => [{ "recommendation_code" => "ECP-H2", "recommendation" => "Add a big wind turbine", "co2_impact" => "HIGH" }],
                      "technical_information" => { "building_environment" => "Air Conditioning", "floor_area" => 10, "main_heating_fuel" => "Natural Gas", "renewable_sources" => "Renewable source", "special_energy_uses" => "Special discount" },
                      "site_services" => { "service_1" => { "description" => "Electricity", "quantity" => 751_445 }, "service_2" => { "description" => "Gas", "quantity" => 72_956 }, "service_3" => { "description" => "Not used", "quantity" => 0 } } }

      actual = use_case.execute(xml: dec_rr,
                                schema_type: "CEPC-3.1",
                                assessment_id: "0000-0000-0000-0000-0000")
      expect(actual).to eq(expectation)
    end
  end
end
