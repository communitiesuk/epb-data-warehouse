RSpec.describe "the parser and the CEPC configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading xml from Cepc" do
    let(:cepc) do
      Samples.xml("CEPC-7.1", "cepc+rr")
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2017-10-13",
                      "report_type" => 3,
                      "valid_until" => "2027-10-12",
                      "related_rrn" => "9999-9999-3333-9999-2222",
                      "inspection_date" => "2017-10-10",
                      "registration_date" => "2017-10-13",
                      "status" => "entered",
                      "language_code" => 1,
                      "scheme_assessor_id" => "EMP/000044",
                      "building_complexity" => "Level 3",
                      "uprn" => 0,
                      "address_line_1" => "99a Address Street",
                      "address_line_2" => "Place Location",
                      "post_town" => "New Town",
                      "postcode" => "A1 1AA",
                      "property_type" => "A1/A2 Retail and Financial/Professional services",
                      "owner" => "Owner",
                      "is_heritage_site" => "N",
                      "methodology" => "SBEM",
                      "calculation_tool" => "CLG, iSBEM, v5.3.a, SBEM, v5.3.a.0",
                      "output_engine" => "EPCgen, v5.3.a.0",
                      "inspection_type" => "Physical",
                      "summary_of_performance" =>
                       { "building_data" =>
                          [{ "analysis_type" => "ACTUAL",
                             "area" => 221.66,
                             "area_exterior" => 578.13,
                             "weather" => "NEW",
                             "q50_infiltration" => 25,
                             "building_w_k" => 756.843,
                             "building_w_m2k" => 1.30912,
                             "building_alpha" => 5.48977,
                             "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } },
                             "global_performance" =>
                              { "kwh_m2_heating" => 162.325,
                                "kwh_m2_cooling" => 0,
                                "kwh_m2_auxiliary" => 2.09834,
                                "kwh_m2_lighting" => 95.5093,
                                "kwh_m2_dhw" => 1.42751,
                                "kwh_m2_equipment" => 17.0788,
                                "kwh_m2_natural_gas" => 0,
                                "kwh_m2_lpg" => 0,
                                "kwh_m2_biogas" => 0,
                                "kwh_m2_oil" => 0,
                                "kwh_m2_coal" => 0,
                                "kwh_m2_anthracite" => 0,
                                "kwh_m2_smokeless" => 0,
                                "kwh_m2_dual_fuel" => 0,
                                "kwh_m2_biomass" => 0,
                                "kwh_m2_supplied" => 261.361,
                                "kwh_m2_waste_heat" => 0,
                                "kwh_m2_district_heating" => 0,
                                "kwh_m2_displaced" => 0,
                                "kwh_m2_pvs" => 0,
                                "kwh_m2_wind" => 0,
                                "kwh_m2_chp" => 0,
                                "kwh_m2_ses" => 0 },
                             "hvac_systems" =>
                              { "hvac_system_data" =>
                                 { "area" => 167.51,
                                   "type" => "Other local room heater - unfanned",
                                   "heat_source" => "Room heater",
                                   "fuel_type" => "Grid Supplied Electricity",
                                   "mj_m2_heating_dem" => 412.486,
                                   "mj_m2_cooling_dem" => 277.439,
                                   "kwh_m2_heating" => 143.224,
                                   "kwh_m2_cooling" => 0,
                                   "kwh_m2_auxiliary" => 0,
                                   "heating_sseff" => 0.8,
                                   "cooling_sseer" => 0,
                                   "heating_gen_seff" => 1,
                                   "cooling_gen_seer" => 0,
                                   "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } } } } },
                           { "analysis_type" => "NOTIONAL",
                             "area" => 221.66,
                             "area_exterior" => 578.13,
                             "weather" => "NEW",
                             "q50_infiltration" => 5,
                             "building_w_k" => 141.605,
                             "building_w_m2k" => 0.244936,
                             "building_alpha" => 12.3616,
                             "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } },
                             "global_performance" =>
                              { "kwh_m2_heating" => 34.2821,
                                "kwh_m2_cooling" => 0,
                                "kwh_m2_auxiliary" => 0.559555,
                                "kwh_m2_lighting" => 53.9687,
                                "kwh_m2_dhw" => 1.64373,
                                "kwh_m2_equipment" => 17.0788,
                                "kwh_m2_natural_gas" => 0,
                                "kwh_m2_lpg" => 0,
                                "kwh_m2_biogas" => 0,
                                "kwh_m2_oil" => 35.9259,
                                "kwh_m2_coal" => 0,
                                "kwh_m2_anthracite" => 0,
                                "kwh_m2_smokeless" => 0,
                                "kwh_m2_dual_fuel" => 0,
                                "kwh_m2_biomass" => 0,
                                "kwh_m2_supplied" => 54.5286,
                                "kwh_m2_waste_heat" => 0,
                                "kwh_m2_district_heating" => 0,
                                "kwh_m2_displaced" => 0,
                                "kwh_m2_pvs" => 0,
                                "kwh_m2_wind" => 0,
                                "kwh_m2_chp" => 0,
                                "kwh_m2_ses" => 0 },
                             "hvac_systems" =>
                              { "hvac_system_data" =>
                                 { "area" => 167.51,
                                   "type" => "Other local room heater - unfanned",
                                   "heat_source" => "Room heater",
                                   "fuel_type" => "Oil",
                                   "mj_m2_heating_dem" => 53.7903,
                                   "mj_m2_cooling_dem" => 153.68,
                                   "kwh_m2_heating" => 18.2439,
                                   "kwh_m2_cooling" => 0,
                                   "kwh_m2_auxiliary" => 0,
                                   "heating_sseff" => 0.819,
                                   "cooling_sseer" => 0,
                                   "heating_gen_seff" => 0,
                                   "cooling_gen_seer" => 0,
                                   "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } } } } },
                           { "analysis_type" => "REFERENCE",
                             "area" => 221.66,
                             "area_exterior" => 578.13,
                             "weather" => "NEW",
                             "q50_infiltration" => 10,
                             "building_w_k" => 458.809,
                             "building_w_m2k" => 0.793609,
                             "building_alpha" => 10,
                             "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } },
                             "global_performance" =>
                              { "kwh_m2_heating" => 94.095,
                                "kwh_m2_cooling" => 34.6462,
                                "kwh_m2_auxiliary" => 3.20299,
                                "kwh_m2_lighting" => 105.031,
                                "kwh_m2_dhw" => 3.16472,
                                "kwh_m2_equipment" => 17.0788,
                                "kwh_m2_natural_gas" => 97.2598,
                                "kwh_m2_lpg" => 0,
                                "kwh_m2_biogas" => 0,
                                "kwh_m2_oil" => 0,
                                "kwh_m2_coal" => 0,
                                "kwh_m2_anthracite" => 0,
                                "kwh_m2_smokeless" => 0,
                                "kwh_m2_dual_fuel" => 0,
                                "kwh_m2_biomass" => 0,
                                "kwh_m2_supplied" => 142.88,
                                "kwh_m2_waste_heat" => 0,
                                "kwh_m2_district_heating" => 0,
                                "kwh_m2_displaced" => 0,
                                "kwh_m2_pvs" => 0,
                                "kwh_m2_wind" => 0,
                                "kwh_m2_chp" => 0,
                                "kwh_m2_ses" => 0 },
                             "hvac_systems" =>
                              { "hvac_system_data" =>
                                 { "area" => 167.51,
                                   "type" => "Other local room heater - unfanned",
                                   "heat_source" => "Room heater",
                                   "fuel_type" => "Natural Gas",
                                   "mj_m2_heating_dem" => 218.634,
                                   "mj_m2_cooling_dem" => 329.959,
                                   "kwh_m2_heating" => 83.1938,
                                   "kwh_m2_cooling" => 40.7357,
                                   "kwh_m2_auxiliary" => 2.44916,
                                   "heating_sseff" => 0.73,
                                   "cooling_sseer" => 2.25,
                                   "heating_gen_seff" => 0,
                                   "cooling_gen_seer" => 0,
                                   "activities" => { "activity" => { "id" => 1305, "area" => 167.51 } } } } }] },
                      "transaction_type" => 6,
                      "asset_rating" => 93,
                      "new_build_benchmark" => 27,
                      "existing_stock_benchmark" => 79,
                      "ser" => 72.8,
                      "ber" => 135.65,
                      "ter" => 39.05,
                      "tyr" => 114.44,
                      "energy_use" => { "energy_consumption_current" => 802.38 },
                      "technical_information" =>
                       { "main_heating_fuel" => "Grid Supplied Electricity",
                         "building_environment" => "Heating and Natural Ventilation",
                         "floor_area" => 222,
                         "building_level" => 3 },
                      "ac_questionnaire" =>
                       { "ac_present" => "No",
                         "ac_rated_output" => { "ac_rating_unknown_flag" => 1 },
                         "ac_inspection_commissioned" => 4 } }

      expect(use_case.execute(xml: cepc,
                              schema_type: "CEPC-7.1",
                              assessment_id: "9999-9999-3333-9999-3333")).to eq(expectation)
    end
  end

  context "when loading xml from Cepc-RR" do
    let(:cepc_rr) do
      Samples.xml("CEPC-7.1", "cepc+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: cepc_rr,
                         schema_type: "CEPC-7.1",
                         assessment_id: "9999-9999-3333-9999-2222"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2017-10-13",
                      "report_type" => 4,
                      "valid_until" => "2027-10-12",
                      "related_rrn" => "9999-9999-3333-9999-3333",
                      "inspection_date" => "2017-10-10",
                      "registration_date" => "2017-10-13",
                      "status" => "entered",
                      "language_code" => 1,
                      "scheme_assessor_id" => "EMP/000044",
                      "building_complexity" => "Level 3",
                      "uprn" => 0,
                      "address_line_1" => "99a Address Street",
                      "address_line_2" => "Place Location",
                      "post_town" => "New Town",
                      "postcode" => "A1 1AA",
                      "property_type" => "A1/A2 Retail and Financial/Professional services",
                      "owner" => "Owner",
                      "is_heritage_site" => "N",
                      "methodology" => "SBEM",
                      "calculation_tool" => "CLG, iSBEM, v5.3.a, SBEM, v5.3.a.0",
                      "output_engine" => "EPCgen, v5.3.a.0",
                      "inspection_type" => "Physical",
                      "short_payback" =>
                       [{ "recommendation_code" => "EPC-L5",
                          "recommendation" =>
                           "Consider replacing T8 lamps with retrofit T5 conversion kit.",
                          "co2_impact" => "HIGH" },
                        { "recommendation_code" => "EPC-L7",
                          "recommendation" =>
                           "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "EPC-V1",
                          "recommendation" =>
                           "In some spaces, the solar gain limit defined in the NCM is exceeded, which might cause overheating. Consider solar control measures such as the application of reflective coating or shading devices to windows.",
                          "co2_impact" => "MEDIUM" }],
                      "long_payback" =>
                       [{ "recommendation_code" => "EPC-E8",
                          "recommendation" =>
                           "Some glazing is poorly insulated. Replace/improve glazing and/or frames.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "EPC-E2",
                          "recommendation" =>
                           "Roof is poorly insulated. Install or improve insulation of roof.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "EPC-R4",
                          "recommendation" => "Consider installing PV.",
                          "co2_impact" => "LOW" }],
                      "technical_information" =>
                       { "building_environment" => "Heating and Natural Ventilation",
                         "floor_area" => 222,
                         "building_level" => 3 } }

      expect(use_case.execute(xml: cepc_rr,
                              schema_type: "CEPC-7.1",
                              assessment_id: "9999-9999-3333-9999-2222")).to eq(expectation)
    end
  end

  context "when loading xml from Dec" do
    let(:dec) do
      Samples.xml("CEPC-7.1", "dec+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: dec,
                         schema_type: "CEPC-7.1",
                         assessment_id: "0000-0000-0000-0000-0005"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2015-12-14",
                      "valid_until" => "2016-12-29",
                      "report_type" => 1,
                      "inspection_date" => "2015-12-09",
                      "registration_date" => "2015-12-14",
                      "status" => "entered",
                      "related_rrn" => "0000-0000-0000-0000-0006",
                      "language_code" => 1,
                      "scheme_assessor_id" => "EMP/000044",
                      "location_description" =>
                       "Refurbished and extended nursery school building with flat and pitched roof areas, double glazed windows and cavity walls.  The building is heated by gas fired boilers.",
                      "uprn" => 0,
                      "address_line_2" => "Place Early Years Centre",
                      "address_line_3" => "Address Road",
                      "post_town" => "Town",
                      "postcode" => "A1 1AA",
                      "property_type" => "Schools And Seasonal Public Buildings",
                      "methodology" => "ORCalc",
                      "calculation_tool" => "DCLG, ORCalc, v3.6.2",
                      "output_engine" => "ORGen v3.6.2",
                      "or_assessment_start_date" => "2014-09-30",
                      "or_assessment_end_date" => "2015-09-30",
                      "building_category" => "S3;",
                      "or_building_data" =>
                       { "internal_environment" => "Heating and Natural Ventilation",
                         "assessment_period_alignment" => "End Of Main Heating Fuel Period",
                         "hvac_system" => "Convectors" },
                      "or_benchmark_data" =>
                       { "main_benchmark" => "Schools And Seasonal Public Buildings",
                         "benchmarks" =>
                          [{ "benchmark" =>
                              { "name" => "Nursery or kindergarten",
                                "benchmark_id" => 1,
                                "area_metric" =>
                                 "Gross floor area measured as RICS Gross Internal Area (GIA)",
                                "floor_area" => 1219.2,
                                "tufa" => 1219.2,
                                "benchmark" => "Schools And Seasonal Public Buildings",
                                "occupancy_level" => "Extended Occupancy",
                                "total_equivalent" => 2437.5 } }] },
                      "or_energy_consumption" =>
                       { "electricity" =>
                          { "consumption" => 59_477,
                            "start_date" => "2014-10-01",
                            "end_date" => "2015-10-01",
                            "estimate" => 0 },
                         "gas" =>
                          { "consumption" => 143_533,
                            "start_date" => "2014-09-30",
                            "end_date" => "2015-09-30",
                            "estimate" => 0 } },
                      "or_previous_data" =>
                       { "previous_rating_1" => { "or" => 75, "ormm" => 12, "oryyyy" => 2014 },
                         "previous_rating_2" => { "or" => 75, "ormm" => 12, "oryyyy" => 2013 } },
                      "dec_annual_energy_summary" =>
                       { "annual_energy_use_electrical" => 49,
                         "annual_energy_use_fuel_thermal" => 118,
                         "renewables_fuel_thermal" => 0,
                         "renewables_electrical" => 0,
                         "typical_thermal_use" => 176,
                         "typical_electrical_use" => 51 },
                      "dec_status" => 0,
                      "reason_type" => 1,
                      "dec_related_party_disclosure" => 4,
                      "this_assessment" =>
                       { "nominated_date" => "2015-12-30",
                         "energy_rating" => 80,
                         "electricity_co2" => 33,
                         "heating_co2" => 28,
                         "renewables_co2" => 0 },
                      "year1_assessment" =>
                       { "nominated_date" => "2014-12-01",
                         "energy_rating" => 75,
                         "electricity_co2" => 30,
                         "heating_co2" => 24,
                         "renewables_co2" => 0 },
                      "year2_assessment" =>
                       { "nominated_date" => "2013-12-01",
                         "energy_rating" => 75,
                         "electricity_co2" => 31,
                         "heating_co2" => 29,
                         "renewables_co2" => 0 },
                      "technical_information" =>
                       { "main_heating_fuel" => "Natural Gas",
                         "building_environment" => "Heating and Natural Ventilation",
                         "floor_area" => 1219.2,
                         "separately_metered_electric_heating" => 0 },
                      "ac_questionnaire" =>
                       { "ac_present" => "No",
                         "ac_rated_output" => { "ac_rating_unknown_flag" => 1 },
                         "ac_inspection_commissioned" => 4 } }
      expect(use_case.execute(xml: dec,
                              schema_type: "CEPC-7.1",
                              assessment_id: "0000-0000-0000-0000-0005")).to eq(expectation)
    end
  end

  context "when loading xml from Dec-RR" do
    let(:dec_rr) do
      Samples.xml("CEPC-7.1", "dec+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: dec_rr,
                         schema_type: "CEPC-7.1",
                         assessment_id: "0000-0000-0000-0000-0006"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2015-12-14",
                      "valid_until" => "2022-12-13",
                      "report_type" => 2,
                      "inspection_date" => "2015-12-09",
                      "registration_date" => "2015-12-14",
                      "status" => "entered",
                      "related_rrn" => "0000-0000-0000-0000-0005",
                      "language_code" => 1,
                      "scheme_assessor_id" => "EMP/000044",
                      "location_description" =>
                       "Refurbished and extended nursery school building with flat and pitched roof areas, double glazed windows and cavity walls.  The building is heated by gas fired boilers.",
                      "uprn" => 0,
                      "address_line_2" => "Place Early Years Centre",
                      "address_line_3" => "Address Road",
                      "post_town" => "Town",
                      "postcode" => "A1 1AA",
                      "is_heritage_site" => "N",
                      "property_type" => "Schools And Seasonal Public Buildings",
                      "methodology" => "ORCalc",
                      "calculation_tool" => "DCLG, ORCalc, v3.6.2",
                      "inspection_type" => "Physical",
                      "output_engine" => "ORGen v3.6.2",
                      "short_payback" =>
                       [{ "recommendation_code" => "OM15",
                          "recommendation" =>
                           "It is recommended that energy management techniques are introduced.  These could include efforts to gain building users commitment to save energy, allocating responsibility for energy to a specific person (champion), setting targets and monitoring.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "CON2",
                          "recommendation" =>
                           "Engage experts to review the HVAC control systems settings and propose alterations and/or upgrades and adjust to suit current occupancy patterns.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "X25",
                          "recommendation" =>
                           "Consider introducing a system of regular checks of Heating, Ventilation and Air Conditioning (HVAC) time and temperature settings and provisions to prevent unauthorised adjustment.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "SP24",
                          "recommendation" =>
                           "Enable power save settings and power down management on computers and associated equipment.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "HS17",
                          "recommendation" =>
                           "If stratification occurs consider re-circulating the air during heating.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "X15",
                          "recommendation" =>
                           "Consider engaging with building users to economise equipment energy consumption with targets, guidance on their achievement and incentives.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "X4",
                          "recommendation" =>
                           "Review staffing arrangements and set up formal systems for delegating authority for Building Energy Management System alterations and/or temporary overrides.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "HW20",
                          "recommendation" =>
                           "Consider fitting 24 hour/7 day time controls onto electric HWS cylinders.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "BF6",
                          "recommendation" =>
                           "Consider how building fabric air tightness could be improved, for example sealing, draught stripping and closing off unused ventilation openings, chimneys.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "SP14",
                          "recommendation" =>
                           "Consider with experts implementation of an energy efficient equipment procurement regime that will upgrade existing equipment and renew in a planned cost-effective programme.",
                          "co2_impact" => "LOW" }],
                      "medium_payback" =>
                       [{ "recommendation_code" => "X3",
                          "recommendation" =>
                           "Consider implementing regular inspections of the building fabric to check on the condition of insulation and sealing measures and removal of accidental ventilation paths.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "BF22",
                          "recommendation" =>
                           "Consider engaging experts to review the condition of the building fabric and propose measures to improve energy performance.  This might include building pressure tests for air tightness and thermography tests for insulation continuity.",
                          "co2_impact" => "LOW" },
                        { "recommendation_code" => "BF9",
                          "recommendation" =>
                           "Consider introducing orimproving cavity wall insulation.",
                          "co2_impact" => "LOW" }],
                      "long_payback" =>
                       [{ "recommendation_code" => "AE3",
                          "recommendation" =>
                           "Consider installing building mounted solar water heating.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "X13",
                          "recommendation" =>
                           "Engage experts to review the building lighting strategies and propose alterations and/or upgrades to daylighting provisions, luminaires and their control systems and an implementation plan.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "BF2",
                          "recommendation" =>
                           "Consider introducing or improving insulation of flat roofs.",
                          "co2_impact" => "MEDIUM" },
                        { "recommendation_code" => "AE4",
                          "recommendation" =>
                           "Consider installing building mounted photovoltaic electricity generating panels.",
                          "co2_impact" => "MEDIUM" }],
                      "technical_information" =>
                       { "main_heating_fuel" => "Natural Gas",
                         "building_environment" => "Heating and Natural Ventilation",
                         "floor_area" => 1219.2,
                         "renewable_sources" => "Not applicable",
                         "special_energy_uses" => "Not applicable" },
                      "site_services" =>
                       { "service_1" => { "description" => "Natural Gas", "quantity" => 143_533 },
                         "service_2" => { "description" => "Electricity", "quantity" => 59_477 },
                         "service_3" => { "description" => "Not used", "quantity" => 0 } } }

      expect(use_case.execute(xml: dec_rr,
                              schema_type: "CEPC-7.1",
                              assessment_id: "0000-0000-0000-0000-0006")).to eq(expectation)
    end
  end

  context "when loading xml from AC-Cert" do
    let(:ac_cert) do
      Samples.xml("CEPC-7.1", "ac-cert+rr")
    end

    it "doesn't error" do
      expect {
        use_case.execute xml: ac_cert,
                         schema_type: "CEPC-7.1",
                         assessment_id: "0000-0000-0000-0000-7777"
      }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2017-10-01",
                      "report_type" => 6,
                      "valid_until" => "2022-07-12",
                      "related_rrn" => "0000-0000-0000-0000-6666",
                      "inspection_date" => "2017-07-13",
                      "registration_date" => "2017-07-13",
                      "status" => "entered",
                      "language_code" => 1,
                      "building_complexity" => "Level 3",
                      "scheme_assessor_id" => "EMP/000044",
                      "uprn" => 0,
                      "address_line_2" => "Place County Council",
                      "address_line_3" => "Place Fire Station",
                      "address_line_4" => "Location Avenue",
                      "post_town" => "Town",
                      "postcode" => "A1 1AA",
                      "is_heritage_site" => "N",
                      "calculation_tool" => "Sterling Accreditation, Sterling e-Volve, v1.2",
                      "equipment_owner" =>
                       { "equipment_owner_name" => "Own Er",
                         "telephone_number" => 100_000_000,
                         "organisation_name" => "Place County Council",
                         "registered_address" =>
                          { "address_line_1" => "Place County Council",
                            "address_line_2" => "County Offices",
                            "address_line_3" => "Location",
                            "post_town" => "Town",
                            "postcode" => "A1 1AA" } },
                      "equipment_operator" =>
                       { "responsible_person" => "Own Er",
                         "telephone_number" => 100_000_000,
                         "organisation_name" => "Place County Council",
                         "registered_address" =>
                          { "address_line_1" => "Place County Council",
                            "address_line_2" => "County Offices",
                            "address_line_3" => "Location",
                            "post_town" => "Town",
                            "postcode" => "A1 1AA" } },
                      "building_name" => "Place Fire Brigade HQ Fire Station",
                      "f_gas_compliant_date" => "11/12/2015",
                      "ac_rated_output" => { "ac_kw_rating" => 140 },
                      "random_sampling_flag" => "Y",
                      "treated_floor_area" => 3771,
                      "ac_system_metered_flag" => 1,
                      "refrigerant_charge_total" => 145,
                      "ac_sub_systems" =>
                       [{ "sub_system_number" => "VOL001/SYS001",
                          "sub_system_description" => "Multi split VRF System",
                          "refrigerant_types" => %w[R22],
                          "sub_system_age" => 1998 },
                        { "sub_system_number" => "VOL001/SYS002 Unit 18",
                          "sub_system_description" => "Split System",
                          "refrigerant_types" => %w[R22],
                          "sub_system_age" => 1997 },
                        { "sub_system_number" => "VOL001/SYS003 Unit 16",
                          "sub_system_description" => "Split System",
                          "refrigerant_types" => %w[R22],
                          "sub_system_age" => 1998 }] }

      expect(use_case.execute(xml: ac_cert,
                              schema_type: "CEPC-7.1",
                              assessment_id: "0000-0000-0000-0000-7777")).to eq(expectation)
    end
  end
end
