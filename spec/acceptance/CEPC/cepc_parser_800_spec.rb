RSpec.describe "the parser and the CEPC configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading xml from Cepc" do
    let(:cepc) do
      Samples.xml("CEPC-8.0.0", "cepc")
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2021-03-19",
                      "report_type" => 3,
                      "valid_until" => "2031-03-18",
                      "inspection_date" => "2021-03-19",
                      "registration_date" => "2021-03-19",
                      "status" => "entered",
                      "language_code" => 1,
                      "scheme_assessor_id" => "TEST000007",
                      "building_complexity" => "Level 3",
                      "address_line_1" => "60 Maple Syrup Road",
                      "address_line_2" => "Candy Mountain",
                      "post_town" => "Big Rock",
                      "postcode" => "NE0 0AA",
                      "property_type" => "A1/A2 Retail and Financial/Professional services",
                      "is_heritage_site" => "N",
                      "uprn" => "UPRN-000000000000",
                      "methodology" => "SBEM",
                      "calculation_tool" => "G-ISBEM Ltd, G-ISBEM, v24.0, SBEM, v5.6.b.0",
                      "output_engine" => "EPCgen, v5.6.b.0",
                      "inspection_type" => "Physical",
                      "summary_of_performance" =>
                       { "building_data" =>
                          [{ "analysis_type" => "REFERENCE",
                             "area" => 951.34,
                             "area_exterior" => 509.17,
                             "weather" => "NEW",
                             "q50_infiltration" => 10,
                             "building_w_k" => 193.204,
                             "building_w_m2k" => 0.379449,
                             "building_alpha" => 10,
                             "activities" => [
                               { "id" => 1067, "area" => 81.32 },
                               { "id" => 1070, "area" => 13.9 },
                               { "id" => 1074, "area" => 258.42 },
                               { "id" => 1078, "area" => 76.99 },
                               { "id" => 1071, "area" => 490.62 },
                               { "id" => 1077, "area" => 30.09 },
                             ],
                             "global_performance" =>
                              { "kwh_m2_heating" => 6.54699,
                                "kwh_m2_cooling" => 30.3968,
                                "kwh_m2_auxiliary" => 1.86372,
                                "kwh_m2_lighting" => 78.7393,
                                "kwh_m2_dhw" => 2.7961,
                                "kwh_m2_equipment" => 19.5261,
                                "kwh_m2_natural_gas" => 9.34308,
                                "kwh_m2_lpg" => 0,
                                "kwh_m2_biogas" => 0,
                                "kwh_m2_oil" => 0,
                                "kwh_m2_coal" => 0,
                                "kwh_m2_anthracite" => 0,
                                "kwh_m2_smokeless" => 0,
                                "kwh_m2_dual_fuel" => 0,
                                "kwh_m2_biomass" => 0,
                                "kwh_m2_supplied" => 110.999,
                                "kwh_m2_waste_heat" => 0,
                                "kwh_m2_district_heating" => 0,
                                "kwh_m2_displaced" => 0,
                                "kwh_m2_pvs" => 0,
                                "kwh_m2_wind" => 0,
                                "kwh_m2_chp" => 0,
                                "kwh_m2_ses" => 0 },
                             "hvac_systems" => [
                               { "area" => 353.64,
                                 "type" => "No Heating or Cooling",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 71.1616,
                                 "mj_m2_cooling_dem" => 13.1255,
                                 "kwh_m2_heating" => 0,
                                 "kwh_m2_cooling" => 0,
                                 "kwh_m2_auxiliary" => 0,
                                 "heating_sseff" => 0,
                                 "cooling_sseer" => 0,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1067, "area" => 81.32 },
                                   { "id" => 1070, "area" => 13.9 },
                                   { "id" => 1074, "area" => 258.42 },
                                 ] },
                               { "area" => 567.61,
                                 "type" => "Split or multi-split system",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 17.0576,
                                 "mj_m2_cooling_dem" => 401.756,
                                 "kwh_m2_heating" => 6.49072,
                                 "kwh_m2_cooling" => 49.5997,
                                 "kwh_m2_auxiliary" => 2.47934,
                                 "heating_sseff" => 0.73,
                                 "cooling_sseer" => 2.25,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1078, "area" => 76.99 },
                                   { "id" => 1071, "area" => 490.62 },
                                 ] },
                               { "area" => 30.09,
                                 "type" => "Other local room heater - unfanned",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 222.205,
                                 "mj_m2_cooling_dem" => 205.785,
                                 "kwh_m2_heating" => 84.553,
                                 "kwh_m2_cooling" => 25.4056,
                                 "kwh_m2_auxiliary" => 12.1545,
                                 "heating_sseff" => 0.73,
                                 "cooling_sseer" => 2.25,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1077, "area" => 30.09 },
                                 ] },
                             ] },
                           { "analysis_type" => "ACTUAL",
                             "area" => 951.34,
                             "area_exterior" => 509.17,
                             "weather" => "NEW",
                             "q50_infiltration" => 10,
                             "building_w_k" => 193.204,
                             "building_w_m2k" => 0.379449,
                             "building_alpha" => 10,
                             "activities" => [
                               { "id" => 1067, "area" => 81.32 },
                               { "id" => 1070, "area" => 13.9 },
                               { "id" => 1074, "area" => 258.42 },
                               { "id" => 1078, "area" => 76.99 },
                               { "id" => 1071, "area" => 490.62 },
                               { "id" => 1077, "area" => 30.09 },
                             ],
                             "global_performance" =>
                               { "kwh_m2_heating" => 6.54699,
                                 "kwh_m2_cooling" => 30.3968,
                                 "kwh_m2_auxiliary" => 1.86372,
                                 "kwh_m2_lighting" => 78.7393,
                                 "kwh_m2_dhw" => 2.7961,
                                 "kwh_m2_equipment" => 19.5261,
                                 "kwh_m2_natural_gas" => 9.34308,
                                 "kwh_m2_lpg" => 0,
                                 "kwh_m2_biogas" => 0,
                                 "kwh_m2_oil" => 0,
                                 "kwh_m2_coal" => 0,
                                 "kwh_m2_anthracite" => 0,
                                 "kwh_m2_smokeless" => 0,
                                 "kwh_m2_dual_fuel" => 0,
                                 "kwh_m2_biomass" => 0,
                                 "kwh_m2_supplied" => 110.999,
                                 "kwh_m2_waste_heat" => 0,
                                 "kwh_m2_district_heating" => 0,
                                 "kwh_m2_displaced" => 0,
                                 "kwh_m2_pvs" => 0,
                                 "kwh_m2_wind" => 0,
                                 "kwh_m2_chp" => 0,
                                 "kwh_m2_ses" => 0 },
                             "hvac_systems" => [
                               { "area" => 353.64,
                                 "type" => "No Heating or Cooling",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 71.1616,
                                 "mj_m2_cooling_dem" => 13.1255,
                                 "kwh_m2_heating" => 0,
                                 "kwh_m2_cooling" => 0,
                                 "kwh_m2_auxiliary" => 0,
                                 "heating_sseff" => 0,
                                 "cooling_sseer" => 0,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1067, "area" => 81.32 },
                                   { "id" => 1070, "area" => 13.9 },
                                   { "id" => 1074, "area" => 258.42 },
                                 ] },
                               { "area" => 567.61,
                                 "type" => "Split or multi-split system",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 17.0576,
                                 "mj_m2_cooling_dem" => 401.756,
                                 "kwh_m2_heating" => 6.49072,
                                 "kwh_m2_cooling" => 49.5997,
                                 "kwh_m2_auxiliary" => 2.47934,
                                 "heating_sseff" => 0.73,
                                 "cooling_sseer" => 2.25,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1078, "area" => 76.99 },
                                   { "id" => 1071, "area" => 490.62 },
                                 ] },
                               { "area" => 30.09,
                                 "type" => "Other local room heater - unfanned",
                                 "heat_source" => "LTHW boiler",
                                 "fuel_type" => "Natural Gas",
                                 "mj_m2_heating_dem" => 222.205,
                                 "mj_m2_cooling_dem" => 205.785,
                                 "kwh_m2_heating" => 84.553,
                                 "kwh_m2_cooling" => 25.4056,
                                 "kwh_m2_auxiliary" => 12.1545,
                                 "heating_sseff" => 0.73,
                                 "cooling_sseer" => 2.25,
                                 "heating_gen_seff" => 0,
                                 "cooling_gen_seer" => 0,
                                 "activities" => [
                                   { "id" => 1077, "area" => 30.09 },
                                 ] },
                             ] }] },
                      "transaction_type" => 1,
                      "asset_rating" => 84,
                      "new_build_benchmark" => 34,
                      "existing_stock_benchmark" => 100,
                      "ser" => 45.61,
                      "ber" => 76.29,
                      "ter" => 31.05,
                      "tyr" => 90.98,
                      "energy_use" => { "energy_consumption_current" => 451.27 },
                      "technical_information" =>
                        { "building_environment" => "Air Conditioning", "building_level" => 3, "floor_area" => 951, "main_heating_fuel" => "Grid Supplied Electricity", "other_fuel_description" => "Other fuel test", "renewable_sources" => "Renewable sources test", "special_energy_uses" => "Test sp" },
                      "ac_questionnaire" =>
                        { "ac_estimated_output" => 3, "ac_inspection_commissioned" => 4, "ac_present" => "No", "ac_rated_output" => { "ac_kw_rating" => 100, "ac_rating_unknown_flag" => 0 } } }
      expect(use_case.execute(xml: cepc,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end

  context "when loading xml from Cepc-RR" do
    let(:cepc_rr) do
      Samples.xml("CEPC-8.0.0", "cepc+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: cepc_rr,
                         schema_type: "CEPC-8.0.0",
                         assessment_id: "0000-0000-0000-0000-0001"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = {
        "issue_date" => "2021-03-19",
        "report_type" => 4,
        "valid_until" => "2031-03-18",
        "related_rrn" => "0000-0000-0000-0000-0000",
        "inspection_date" => "2021-03-19",
        "registration_date" => "2021-03-19",
        "status" => "entered",
        "language_code" => 1,
        "scheme_assessor_id" => "EES/024389",
        "building_complexity" => "Level 3",
        "address_line_1" => "60 Maple Syrup",
        "address_line_2" => "Big Rock",
        "post_town" => "Candy Mountain",
        "postcode" => "NE0 0AA",
        "property_type" => "A1/A2 Retail and Financial/Professional services",
        "is_heritage_site" => "N",
        "uprn" => "UPRN-00000000000",
        "methodology" => "SBEM",
        "calculation_tool" => "G-ISBEM Ltd, G-ISBEM, v24.0, SBEM, v5.6.b.0",
        "output_engine" => "EPCgen, v5.6.b.0",
        "inspection_type" => "Physical",
        "short_payback" =>
                       [{ "recommendation_code" => "EPC-L5",
                          "recommendation" =>
                           "Consider replacing T8 lamps with retrofit T5 conversion kit.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "EPC-L7",
                          "recommendation" =>
                           "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-V1",
                          "recommendation" =>
                           "In some spaces, the solar gain limit defined in the NCM is exceeded, which might cause overheating. Consider solar control measures such as the application of reflective coating or shading devices to windows.",
                          "co2_impact" => "MEDIUM" }],
        "long_payback" =>
                       [{ "recommendation_code" => "EPC-R2",
                          "recommendation" => "Consider installing building mounted wind turbine(s).",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-R3",
                          "recommendation" => "Consider installing solar water heating.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-R4",
                          "recommendation" => "Consider installing PV.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-H2",
                          "recommendation" => "Add time control to heating system.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-H7",
                          "recommendation" => "Add optimum start/stop to the heating system.",
                          "co2_impact" => "LOW" }],
        "technical_information" =>
                       { "building_environment" => "Air Conditioning",
                         "floor_area" => 951,
                         "building_level" => 3 },
      }
      expect(use_case.execute(xml: cepc_rr,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0001")).to eq(expectation)
    end
  end

  context "when loading xml from Dec" do
    let(:dec) do
      Samples.xml("CEPC-8.0.0", "dec+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: dec,
                         schema_type: "CEPC-8.0.0",
                         assessment_id: "0000-0000-0000-0000-0000"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = {
        "issue_date" => "2021-10-12",
        "valid_until" => "2022-01-31",
        "report_type" => 1,
        "inspection_date" => "2021-09-02",
        "registration_date" => "2021-10-12",
        "status" => "entered",
        "related_rrn" => "0000-0000-0000-0000-0001",
        "language_code" => 1,
        "scheme_assessor_id" => "TEST000000",
        "location_description" => "Swimming pool with gumnasium.",
        "uprn" => "RRN-0000-0000-0000-0000-0000",
        "address_line_1" => "Swim & Fitness Centre",
        "address_line_2" => "Swimming Lane",
        "post_town" => "Floatering",
        "postcode" => "A00 0AA",
        "property_type" => "Fitness And Health Centre; Swimming Pool Centre",
        "occupier" => "Swimming corp",
        "methodology" => "ORCalc",
        "calculation_tool" => "CLG, ORCalc, v4.0.4",
        "output_engine" => "ORGen v4.0.4",
        "or_assessment_start_date" => "2020-08-31",
        "or_assessment_end_date" => "2021-08-31",
        "building_category" => "H7; H6;",
        "or_building_data" =>
                       { "internal_environment" => "Heating and Mechanical Ventilation",
                         "assessment_period_alignment" => "End Of Main Heating Fuel Period",
                         "hvac_system" => "Radiators" },
        "or_benchmark_data" =>
                       { "main_benchmark" => "Swimming Pool Centre",
                         "benchmarks" =>
                           [{ "name" => "Gymnasium",
                              "benchmark_id" => 1,
                              "area_metric" => "Gross floor area measured as RICS Gross Internal Area (GIA)",
                              "floor_area" => 110.382,
                              "tufa" => 110.382,
                              "benchmark" => "Fitness And Health Centre",
                              "occupancy_level" => "Standard Occupancy" },
                            { "name" => "Swimming pool",
                              "benchmark_id" => 2,
                              "area_metric" => "Gross floor area measured as RICS Gross Internal Area (GIA)",
                              "floor_area" => 1358.936,
                              "tufa" => 1358.936,
                              "benchmark" => "Swimming Pool Centre",
                              "occupancy_level" => "Standard Occupancy" }] },
        "or_energy_consumption" =>
                       { "electricity" =>
                          { "consumption" => 126_161,
                            "start_date" => "2020-09-01",
                            "end_date" => "2021-08-31",
                            "estimate" => 0 },
                         "gas" =>
                          { "consumption" => 805_167,
                            "start_date" => "2020-09-01",
                            "end_date" => "2021-08-31",
                            "estimate" => 0 } },
        "or_usable_floor_area" =>
                       { "ufa_1" => { "name" => "Basement Plant", "floor_area" => 118.16 },
                         "ufa_2" => { "name" => "Basement void around pool", "floor_area" => 179.673 },
                         "ufa_3" => { "name" => "Ground Plant", "floor_area" => 146.223 },
                         "ufa_4" => { "name" => "First Floor Plant", "floor_area" => 49.807 },
                         "total_ufa" => 493.863 },
        "or_previous_data" => { "asset_rating" => 45 },
        "renewable_energy_source" =>
                       [{ "start_date" => "2020-09-01",
                          "end_date" => "2021-08-31",
                          "name" => "CHP",
                          "generation" => 24_589,
                          "energy_type" => 0 }],
        "dec_annual_energy_summary" =>
                       { "annual_energy_use_electrical" => 86.1,
                         "annual_energy_use_fuel_thermal" => 548.82,
                         "renewables_fuel_thermal" => 0,
                         "renewables_electrical" => 16.3,
                         "typical_thermal_use" => 1196.24,
                         "typical_electrical_use" => 238.61 },
        "dec_status" => 0,
        "reason_type" => 1,
        "dec_related_party_disclosure" => 1,
        "this_assessment" =>
                       { "nominated_date" => "2021-09-01",
                         "energy_rating" => 42,
                         "electricity_co2" => 70,
                         "heating_co2" => 156,
                         "renewables_co2" => 13 },
        "technical_information" =>
                       { "main_heating_fuel" => "Natural Gas",
                         "building_environment" => "Heating and Mechanical Ventilation",
                         "floor_area" => 1469.318,
                         "separately_metered_electric_heating" => 0 },
        "ac_questionnaire" =>
                       { "ac_present" => "Yes",
                         "ac_rated_output" => { "ac_kw_rating" => 30 },
                         "ac_inspection_commissioned" => 1 },
      }

      expect(use_case.execute(xml: dec,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end

  context "when loading xml from Dec with a data point which exceeds the character limit" do
    let(:dec) do
      Samples.xml("CEPC-8.0.0", "dec_exceeds_character_count")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: dec,
                         schema_type: "CEPC-8.0.0",
                         assessment_id: "0000-0000-0000-0000-0000"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = {
        "issue_date" => "2021-10-12",
        "valid_until" => "2022-01-31",
        "report_type" => 1,
        "inspection_date" => "2021-09-02",
        "registration_date" => "2021-10-12",
        "status" => "entered",
        "related_rrn" => "0000-0000-0000-0000-0001",
        "language_code" => 1,
        "scheme_assessor_id" => "TEST000000",
        "location_description" => "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi...",
        "uprn" => "RRN-0000-0000-0000-0000-0000",
        "address_line_1" => "Swim & Fitness Centre",
        "address_line_2" => "Swimming Lane",
        "post_town" => "Floatering",
        "postcode" => "A00 0AA",
        "property_type" => "Fitness And Health Centre; Swimming Pool Centre",
        "occupier" => "Swimming corp",
        "methodology" => "ORCalc",
        "calculation_tool" => "CLG, ORCalc, v4.0.4",
        "output_engine" => "ORGen v4.0.4",
        "or_assessment_start_date" => "2020-08-31",
        "or_assessment_end_date" => "2021-08-31",
        "building_category" => "H7; H6;",
        "or_building_data" =>
          { "internal_environment" => "Heating and Mechanical Ventilation",
            "assessment_period_alignment" => "End Of Main Heating Fuel Period",
            "hvac_system" => "Radiators" },
        "or_benchmark_data" =>
          { "main_benchmark" => "Swimming Pool Centre",
            "benchmarks" =>
              [{ "name" => "Gymnasium",
                 "benchmark_id" => 1,
                 "area_metric" => "Gross floor area measured as RICS Gross Internal Area (GIA)",
                 "floor_area" => 110.382,
                 "tufa" => 110.382,
                 "benchmark" => "Fitness And Health Centre",
                 "occupancy_level" => "Standard Occupancy" },
               { "name" => "Swimming pool",
                 "benchmark_id" => 2,
                 "area_metric" => "Gross floor area measured as RICS Gross Internal Area (GIA)",
                 "floor_area" => 1358.936,
                 "tufa" => 1358.936,
                 "benchmark" => "Swimming Pool Centre",
                 "occupancy_level" => "Standard Occupancy" }] },
        "or_energy_consumption" =>
          { "electricity" =>
              { "consumption" => 126_161,
                "start_date" => "2020-09-01",
                "end_date" => "2021-08-31",
                "estimate" => 0 },
            "gas" =>
              { "consumption" => 805_167,
                "start_date" => "2020-09-01",
                "end_date" => "2021-08-31",
                "estimate" => 0 } },
        "or_usable_floor_area" =>
          { "ufa_1" => { "name" => "Basement Plant", "floor_area" => 118.16 },
            "ufa_2" => { "name" => "Basement void around pool", "floor_area" => 179.673 },
            "ufa_3" => { "name" => "Ground Plant", "floor_area" => 146.223 },
            "ufa_4" => { "name" => "First Floor Plant", "floor_area" => 49.807 },
            "total_ufa" => 493.863 },
        "or_previous_data" => { "asset_rating" => 45 },
        "renewable_energy_source" =>
          [{ "start_date" => "2020-09-01",
             "end_date" => "2021-08-31",
             "name" => "CHP",
             "generation" => 24_589,
             "energy_type" => 0 }],
        "dec_annual_energy_summary" =>
          { "annual_energy_use_electrical" => 86.1,
            "annual_energy_use_fuel_thermal" => 548.82,
            "renewables_fuel_thermal" => 0,
            "renewables_electrical" => 16.3,
            "typical_thermal_use" => 1196.24,
            "typical_electrical_use" => 238.61 },
        "dec_status" => 0,
        "reason_type" => 1,
        "dec_related_party_disclosure" => 1,
        "this_assessment" =>
          { "nominated_date" => "2021-09-01",
            "energy_rating" => 42,
            "electricity_co2" => 70,
            "heating_co2" => 156,
            "renewables_co2" => 13 },
        "technical_information" =>
          { "main_heating_fuel" => "Natural Gas",
            "building_environment" => "Heating and Mechanical Ventilation",
            "floor_area" => 1469.318,
            "separately_metered_electric_heating" => 0 },
        "ac_questionnaire" =>
          { "ac_present" => "Yes",
            "ac_rated_output" => { "ac_kw_rating" => 30 },
            "ac_inspection_commissioned" => 1 },
      }
      expect(use_case.execute(xml: dec,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end

  context "when loading xml from Dec-RR" do
    let(:dec_rr) do
      Samples.xml("CEPC-8.0.0", "dec+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: dec_rr,
                         schema_type: "CEPC-8.0.0",
                         assessment_id: "0000-0000-0000-0000-0000"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = {
        "issue_date" => "2021-11-12",
        "valid_until" => "2031-11-11",
        "report_type" => 2,
        "inspection_date" => "2021-08-02",
        "registration_date" => "2021-11-12",
        "status" => "entered",
        "related_rrn" => "0000-0000-0000-0000-0000",
        "language_code" => 1,
        "scheme_assessor_id" => "TEST000000",
        "location_description" => "Swimming pool with gumnasium.",
        "uprn" => "RRN-0000-0000-0000-0000-0000",
        "address_line_1" => "Swim & Fitness Centre",
        "address_line_2" => "Swimming Lane",
        "post_town" => "Floatering",
        "postcode" => "A00 0AA",
        "is_heritage_site" => "Y",
        "property_type" => "Fitness And Health Centre; Swimming Pool Centre",
        "occupier" => "Swimming corp",
        "methodology" => "ORCalc",
        "calculation_tool" => "CLG, ORCalc, v4.0.4",
        "inspection_type" => "Physical",
        "output_engine" => "ORGen v4.0.4",
        "short_payback" =>
                       [{ "recommendation_code" => "X17",
                          "recommendation" =>
                           "Consider a programme of fitting energy meters to the pool complex as part of the service and maintenance regime.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "CON15",
                          "recommendation" =>
                           "Consider installing weather compensator controls on heating and cooling systems.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "P1",
                          "recommendation" => "Ensure pool covers are in place whenever possible.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "HW20",
                          "recommendation" =>
                           "Consider fitting 24 hour/7 day time controls onto electric HWS cylinders.",
                          "co2_impact" => "MEDIUM" }],
        "medium_payback" =>
                       [{ "recommendation_code" => "BF9",
                          "recommendation" =>
                           "Consider introducing or improving cavity wall insulation.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "X18",
                          "recommendation" =>
                           "Consider with experts how the pool complex air tightness can be improved, for example sealed better and fitted with air lock or revolving doors.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "P3",
                          "recommendation" =>
                           "Consider with experts the benefits of installing a heat recovery system to pool water and pool hall heating.",
                          "co2_impact" => "MEDIUM" }],
        "long_payback" =>
                       [{ "recommendation_code" => "AE1",
                          "recommendation" => "Consider installing building mounted wind turbine(s).",
                          "co2_impact" => "MEDIUM" }],
        "other_payback" =>
                       [{ "recommendation_code" => "None",
                          "recommendation" =>
                           "The pool cover is currently out of order, consider getting it fixed as soon as possible.",
                          "co2_impact" => "HIGH" }],
        "technical_information" =>
                       { "main_heating_fuel" => "Natural Gas",
                         "building_environment" => "Heating and Mechanical Ventilation",
                         "floor_area" => 1469.318,
                         "renewable_sources" => "CHP: 24,656.55 kWh Electricity" },
        "site_services" =>
                       { "service_1" => { "description" => "Natural Gas", "quantity" => 806_390 },
                         "service_2" => { "description" => "Electricity", "quantity" => 126_508 },
                         "service_3" => { "description" => "Not used", "quantity" => 0 } },
      }
      expect(use_case.execute(xml: dec_rr,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0001")).to eq(expectation)
    end
  end

  context "when loading xml from AC-Cert" do
    let(:ac_cert) do
      Samples.xml("CEPC-8.0.0", "ac-cert+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: ac_cert,
                         schema_type: "CEPC-8.0.0",
                         assessment_id: "0000-0000-0000-0000-0000"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2020-12-12",
                      "report_type" => 6,
                      "valid_until" => "2025-12-12",
                      "related_rrn" => "0000-0000-0000-0000-0001",
                      "inspection_date" => "2020-12-12",
                      "registration_date" => "2020-12-12",
                      "status" => "entered",
                      "language_code" => 1,
                      "building_complexity" => "Level 3",
                      "scheme_assessor_id" => "TEST000001",
                      "uprn" => "UPRN-00000000000",
                      "address_line_1" => "24 Some Street",
                      "post_town" => "Town",
                      "postcode" => "NE0 0AA",
                      "is_heritage_site" => "N",
                      "calculation_tool" => "Some Accreditation, Sterling e-Volve, v1.2",
                      "equipment_owner" =>
                        [{ "equipment_owner_name" => "Manager",
                           "telephone_number" => 0,
                           "organisation_name" => "Organisation Plc",
                           "registered_address" => { "address_line_1" => "Organisation House", "address_line_2" => "Business Park", "post_town" => "Town", "postcode" => "NE0 0AA" } }],
                      "equipment_operator" =>
                        [{ "responsible_person" => "Operator Person",
                           "telephone_number" => 0,
                           "organisation_name" => "Organisation Plc",
                           "registered_address" => { "postcode" => "NE0 0AA" } },
                         { "responsible_person" => "Operator Person",
                           "telephone_number" => 0,
                           "organisation_name" => "Organisation Plc",
                           "registered_address" => { "postcode" => "NE0 0AA" } }],
                      "building_name" => "24 Some Street",
                      "f_gas_compliant_date" => "Not Provided",
                      "ac_rated_output" => { "ac_kw_rating" => 28 },
                      "random_sampling_flag" => "N",
                      "treated_floor_area" => 141,
                      "ac_system_metered_flag" => 1,
                      "refrigerant_charge_total" => 10,
                      "ac_sub_systems" =>
                       [{ "sub_system_number" => "VOL001/SYS001",
                          "sub_system_description" => "Mitsubishi split system",
                          "refrigerant_types" => %w[R410A],
                          "sub_system_age" => 2016 },
                        { "sub_system_number" => "VOL001/SYS002",
                          "sub_system_description" => "Mitsubishi split system",
                          "refrigerant_types" => %w[R410A],
                          "sub_system_age" => 2015 }] }
      expect(use_case.execute(xml: ac_cert,
                              schema_type: "CEPC-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq(expectation)
    end
  end
end
