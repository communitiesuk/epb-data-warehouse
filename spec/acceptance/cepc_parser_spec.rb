RSpec.describe "the parser and the rdsap configuration" do
  context "when loading xml from Cepc" do
    let(:config) do
      XmlPresenter::Cepc::Cepc800ExportConfiguration.new
    end

    let(:parser) do
      XmlPresenter::Parser.new(specified_report: { root_node: "Report", sub_node: "RRN", sub_node_value: "0000-0000-0000-0000-0000" }, **config.to_args)
    end

    let(:cepc) do
      Samples.xml("CEPC-8.0.0", "cepc")
    end

    it "doesn't error" do
      expect { parser.parse(cepc) }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "issue_date" => "2021-03-19",
                      "rrn" => "0000-0000-0000-0000-0000",
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
                             "activities" => { "activity" => { "id" => 1077, "area" => 30.09 } },
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
                             "hvac_systems" =>
                              { "hvac_system_data" =>
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
                                   "activities" => { "activity" => { "id" => 1077, "area" => 30.09 } } } } }] },
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
                       { "main_heating_fuel" => "Grid Supplied Electricity",
                         "building_environment" => "Air Conditioning",
                         "floor_area" => 951,
                         "building_level" => 3 },
                      "ac_questionnaire" =>
                       { "ac_present" => "No",
                         "ac_rated_output" => { "ac_rating_unknown_flag" => 1 },
                         "ac_inspection_commissioned" => 4 } }
      expect(parser.parse(cepc)).to eq(expectation)
    end
  end

  context "when loading xml from Dec" do
    let(:config) do
      XmlPresenter::Cepc::Cepc800ExportConfiguration.new
    end

    let(:parser) do
      XmlPresenter::Parser.new(specified_report: { root_node: "Report", sub_node: "RRN", sub_node_value: "0000-0000-0000-0000-0000" }, **config.to_args)
    end

    let(:dec) do
      Samples.xml("CEPC-8.0.0", "dec")
    end

    it "doesn't error" do
      expect { parser.parse(dec) }.not_to raise_error
    end

    it "parses the document in the expected format" do
      expectation = { "rrn" => "0000-0000-0000-0000-0000",
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
                      "address_line_1" => "Fitness Centre",
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
                          [{ "benchmark" =>
                              { "name" => "Swimming pool",
                                "benchmark_id" => 2,
                                "area_metric" =>
                                 "Gross floor area measured as RICS Gross Internal Area (GIA)",
                                "floor_area" => 1358.936,
                                "tufa" => 1358.936,
                                "benchmark" => "Swimming Pool Centre",
                                "occupancy_level" => "Standard Occupancy" } }] },
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
                         "ac_inspection_commissioned" => 1 } }
      expect(parser.parse(dec)).to eq(expectation)
    end
  end
end
