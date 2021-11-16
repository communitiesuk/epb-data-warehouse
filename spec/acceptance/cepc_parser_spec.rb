RSpec.describe "the parser and the rdsap configuration" do
  context "when loading xml from RdSap" do
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
end
