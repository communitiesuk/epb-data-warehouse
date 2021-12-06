RSpec.describe "the parser and the CEPC (NI) configuration" do
  let(:use_case) { UseCase::ParseXmlCertificate.new }

  context "when loading XML for CEPC (Northern Ireland)" do
    let(:cepc_rr) do
      Samples.xml "CEPC-NI-8.0.0", "cepc+rr"
    end

    context "when reading in the main assessment" do
      it "parses the document in the expected format" do
        expectation = {
          "issue_date" => "2020-11-16",
          "report_type" => 3,
          "valid_until" => "2030-11-15",
          "related_rrn" => "0000-0000-0000-0000-0001",
          "inspection_date" => "2020-09-23",
          "registration_date" => "2020-11-16",
          "status" => "entered",
          "language_code" => 1,
          "scheme_assessor_id" => "TEST000002",
          "building_complexity" => "Level 4",
          "uprn" => "UPRN-000011112222",
          "address_line_1" => "Unit 1",
          "address_line_2" => "Small Retail Park",
          "address_line_3" => "Small Road",
          "post_town" => "Smallville",
          "postcode" => "AB1 2AD",
          "property_type" =>
            "D2 General Assembly and Leisure plus Night Clubs and Theatres",
          "is_heritage_site" => "N",
          "methodology" => "SBEM",
          "calculation_tool" =>
            "DesignBuilder Software Ltd, DesignBuilder SBEM, v6.1.7, SBEM, v4.1.h.0",
          "output_engine" => "EPCgen, v4.1.h.0",
          "inspection_type" => "Physical",
          "summary_of_performance" =>
            { "building_data" =>
                [{ "analysis_type" => "ACTUAL",
                   "area" => 1498.44,
                   "area_exterior" => 3039.83,
                   "weather" => "BEL",
                   "q50_infiltration" => 15,
                   "building_w_k" => 1540.39,
                   "building_w_m2k" => 0.506736,
                   "building_alpha" => 21.0595,
                   "activities" => { "activity" => { "id" => 1191, "area" => 138.41 } },
                   "global_performance" =>
                     { "kwh_m2_heating" => 103.11,
                       "kwh_m2_cooling" => 15.1875,
                       "kwh_m2_auxiliary" => 93.3898,
                       "kwh_m2_lighting" => 33.5813,
                       "kwh_m2_dhw" => 231.511,
                       "kwh_m2_equipment" => 64.8436,
                       "kwh_m2_natural_gas" => 316.883,
                       "kwh_m2_lpg" => 0,
                       "kwh_m2_biogas" => 0,
                       "kwh_m2_oil" => 0,
                       "kwh_m2_coal" => 0,
                       "kwh_m2_anthracite" => 0,
                       "kwh_m2_smokeless" => 0,
                       "kwh_m2_dual_fuel" => 0,
                       "kwh_m2_biomass" => 0,
                       "kwh_m2_supplied" => 159.896,
                       "kwh_m2_waste_heat" => 0,
                       "kwh_m2_district_heating" => 0,
                       "kwh_m2_displaced" => 0,
                       "kwh_m2_pvs" => 0,
                       "kwh_m2_wind" => 0,
                       "kwh_m2_chp" => 0,
                       "kwh_m2_ses" => 0 },
                   "hvac_systems" =>
                     { "hvac_system_data" =>
                         { "area" => 12.39,
                           "type" => "Other local room heater - unfanned",
                           "heat_source" => "Direct or storage electric heater",
                           "fuel_type" => "Grid Supplied Electricity",
                           "mj_m2_heating_dem" => 193.447,
                           "mj_m2_cooling_dem" => 134.328,
                           "kwh_m2_heating" => 67.1692,
                           "kwh_m2_cooling" => 0,
                           "kwh_m2_auxiliary" => 5.13969,
                           "heating_sseff" => 0.8,
                           "cooling_sseer" => 0,
                           "heating_gen_seff" => 1,
                           "cooling_gen_seer" => 0,
                           "activities" => { "activity" => { "id" => 1207, "area" => 12.39 } } } } },
                 { "analysis_type" => "NOTIONAL",
                   "area" => 1498.44,
                   "area_exterior" => 3039.83,
                   "weather" => "BEL",
                   "q50_infiltration" => 5,
                   "building_w_k" => 1014.15,
                   "building_w_m2k" => 0.333621,
                   "building_alpha" => 10.6756,
                   "activities" => { "activity" => { "id" => 1191, "area" => 138.41 } },
                   "global_performance" =>
                     { "kwh_m2_heating" => 15.6057,
                       "kwh_m2_cooling" => 9.20684,
                       "kwh_m2_auxiliary" => 48.3755,
                       "kwh_m2_lighting" => 15.9792,
                       "kwh_m2_dhw" => 192.07,
                       "kwh_m2_equipment" => 64.8436,
                       "kwh_m2_natural_gas" => 203.871,
                       "kwh_m2_lpg" => 0,
                       "kwh_m2_biogas" => 0,
                       "kwh_m2_oil" => 0.257492,
                       "kwh_m2_coal" => 0,
                       "kwh_m2_anthracite" => 0,
                       "kwh_m2_smokeless" => 0,
                       "kwh_m2_dual_fuel" => 0,
                       "kwh_m2_biomass" => 0,
                       "kwh_m2_supplied" => 77.1095,
                       "kwh_m2_waste_heat" => 0,
                       "kwh_m2_district_heating" => 0,
                       "kwh_m2_displaced" => 0,
                       "kwh_m2_pvs" => 0,
                       "kwh_m2_wind" => 0,
                       "kwh_m2_chp" => 0,
                       "kwh_m2_ses" => 0 },
                   "hvac_systems" =>
                     { "hvac_system_data" =>
                         { "area" => 12.39,
                           "type" => "Other local room heater - unfanned",
                           "heat_source" => "Direct or storage electric heater",
                           "fuel_type" => "Oil",
                           "mj_m2_heating_dem" => 88.7893,
                           "mj_m2_cooling_dem" => 172.508,
                           "kwh_m2_heating" => 31.1409,
                           "kwh_m2_cooling" => 0,
                           "kwh_m2_auxiliary" => 4.97389,
                           "heating_sseff" => 0.792,
                           "cooling_sseer" => 0,
                           "heating_gen_seff" => 0,
                           "cooling_gen_seer" => 0,
                           "activities" => { "activity" => { "id" => 1207, "area" => 12.39 } } } } },
                 { "analysis_type" => "REFERENCE",
                   "area" => 1498.44,
                   "area_exterior" => 3039.83,
                   "weather" => "BEL",
                   "q50_infiltration" => 10,
                   "building_w_k" => 1861.73,
                   "building_w_m2k" => 0.612446,
                   "building_alpha" => 10,
                   "activities" => { "activity" => { "id" => 1191, "area" => 138.41 } },
                   "global_performance" =>
                     { "kwh_m2_heating" => 160.688,
                       "kwh_m2_cooling" => 13.6134,
                       "kwh_m2_auxiliary" => 11.6801,
                       "kwh_m2_lighting" => 35.3177,
                       "kwh_m2_dhw" => 356.825,
                       "kwh_m2_equipment" => 64.8436,
                       "kwh_m2_natural_gas" => 517.514,
                       "kwh_m2_lpg" => 0,
                       "kwh_m2_biogas" => 0,
                       "kwh_m2_oil" => 0,
                       "kwh_m2_coal" => 0,
                       "kwh_m2_anthracite" => 0,
                       "kwh_m2_smokeless" => 0,
                       "kwh_m2_dual_fuel" => 0,
                       "kwh_m2_biomass" => 0,
                       "kwh_m2_supplied" => 60.6112,
                       "kwh_m2_waste_heat" => 0,
                       "kwh_m2_district_heating" => 0,
                       "kwh_m2_displaced" => 0,
                       "kwh_m2_pvs" => 0,
                       "kwh_m2_wind" => 0,
                       "kwh_m2_chp" => 0,
                       "kwh_m2_ses" => 0 },
                   "hvac_systems" =>
                     { "hvac_system_data" =>
                         { "area" => 12.39,
                           "type" => "Other local room heater - unfanned",
                           "heat_source" => "Direct or storage electric heater",
                           "fuel_type" => "Natural Gas",
                           "mj_m2_heating_dem" => 221.798,
                           "mj_m2_cooling_dem" => 258.595,
                           "kwh_m2_heating" => 84.3979,
                           "kwh_m2_cooling" => 31.9253,
                           "kwh_m2_auxiliary" => 2.89445,
                           "heating_sseff" => 0.73,
                           "cooling_sseer" => 2.25,
                           "heating_gen_seff" => 0,
                           "cooling_gen_seer" => 0,
                           "activities" => { "activity" => { "id" => 1207, "area" => 12.39 } } } } }] },
          "transaction_type" => 4,
          "asset_rating" => 71,
          "new_build_benchmark" => 39,
          "existing_stock_benchmark" => 103,
          "ser" => 102.36,
          "ber" => 145.41,
          "ter" => 79.31,
          "tyr" => 211.5,
          "energy_use" => { "energy_consumption_current" => 790.12 },
          "technical_information" =>
            { "main_heating_fuel" => "Natural Gas",
              "building_environment" => "Air Conditioning",
              "floor_area" => 1498,
              "building_level" => 4 },
          "ac_questionnaire" =>
            { "ac_present" => "No",
              "ac_rated_output" => { "ac_rating_unknown_flag" => 1 },
              "ac_inspection_commissioned" => 4 },
        }

        expect(use_case.execute(xml: cepc_rr,
                                schema_type: "CEPC-NI-8.0.0",
                                assessment_id: "0000-0000-0000-0000-0000")).to eq expectation
      end
    end

    context "when importing the CEPC recommendation report" do
      it "parses the document in the expect format" do
        expectation = {
          "issue_date" => "2020-11-16",
          "report_type" => 4,
          "valid_until" => "2030-11-15",
          "related_rrn" => "0000-0000-0000-0000-0000",
          "inspection_date" => "2020-10-23",
          "registration_date" => "2020-11-11",
          "status" => "entered",
          "language_code" => 1,
          "scheme_assessor_id" => "TEST000001",
          "building_complexity" => "Level 4",
          "uprn" => "UPRN-000011112222",
          "address_line_1" => "Unit 1",
          "address_line_2" => "Small Retail Park",
          "address_line_3" => "Small Road",
          "post_town" => "Smallville",
          "postcode" => "AB1 2AD",
          "property_type" =>
                         "D2 General Assembly and Leisure plus Night Clubs and Theatres",
          "is_heritage_site" => "N",
          "methodology" => "SBEM",
          "calculation_tool" =>
                         "DesignBuilder Software Ltd, DesignBuilder SBEM, v6.1.7, SBEM, v4.1.h.0",
          "output_engine" => "EPCgen, v4.1.h.0",
          "inspection_type" => "Physical",
          "short_payback" =>
             [{ "recommendation_code" => "EPC-W1",
                "recommendation" => "Install more efficient water heater.",
                "co2_impact" => "MEDIUM" },
              { "recommendation_code" => "EPC-L5",
                "recommendation" =>
                 "Consider replacing T8 lamps with retrofit T5 conversion kit.",
                "co2_impact" => "LOW" }],
          "long_payback" =>
             [{ "recommendation_code" => "EPC-E5",
                "recommendation" =>
                 "Some windows have high U-values - consider installing secondary glazing.",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "EPC-R3",
                "recommendation" => "Consider installing solar water heating.",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "EPC-E7",
                "recommendation" =>
                 "Carry out a pressure test, identify and treat identified air leakage. Enter result in EPC calculation.",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "EPC-E8",
                "recommendation" =>
                 "Some glazing is poorly insulated. Replace/improve glazing and/or frames.",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "EPC-R4",
                "recommendation" => "Consider installing PV.",
                "co2_impact" => "LOW" }],
          "other_payback" =>
             [{ "recommendation_code" => "USER",
                "recommendation" => "Consider replacing remaining fluorescent lighting",
                "co2_impact" => "MEDIUM" }],
          "technical_information" =>
             { "building_environment" => "Air Conditioning",
               "floor_area" => 1498,
               "building_level" => 4 },
        }

        expect(use_case.execute(xml: cepc_rr,
                                schema_type: "CEPC-NI-8.0.0",
                                assessment_id: "0000-0000-0000-0000-0001")).to eq expectation
      end
    end
  end

  context "when loading XML for DEC (CEPC, Northern Ireland)" do
    let(:dec_rr) { Samples.xml "CEPC-NI-8.0.0", "dec+rr" }

    context "when importing the main DEC assessment" do
      it "parses the document in the expected format" do
        expectation = {
          "issue_date" => "2020-11-12",
          "valid_until" => "2020-12-17",
          "report_type" => 1,
          "inspection_date" => "2020-11-12",
          "registration_date" => "2020-11-12",
          "status" => "entered",
          "related_rrn" => "0000-0000-0000-0000-0001",
          "language_code" => 1,
          "scheme_assessor_id" => "TEST000001",
          "location_description" => "5 storey modern office building.",
          "uprn" => "UPRN-000011112222",
          "address_line_1" => "1 Court Lane",
          "address_line_2" => "Made-Up District",
          "address_line_3" => "Fake Village",
          "post_town" => "Anytown",
          "postcode" => "BT7 1AA",
          "property_type" => "General Office",
          "methodology" => "ORCalc",
          "calculation_tool" => "CLG, ORCalc, v4.0.4",
          "output_engine" => "ORGen v4.0.4",
          "or_assessment_start_date" => "2018-11-01",
          "or_assessment_end_date" => "2019-11-01",
          "building_category" => "C1;",
          "or_building_data" =>
             { "internal_environment" => "Heating and Natural Ventilation",
               "assessment_period_alignment" => "Start Of Main Heating Fuel Period",
               "hvac_system" => "Radiators" },
          "or_benchmark_data" =>
             { "main_benchmark" => "General Office",
               "benchmarks" =>
                [{ "benchmark" =>
                    { "name" => "Offices - cellular, naturally ventilated",
                      "benchmark_id" => 1,
                      "area_metric" =>
                       "Gross floor area measured as RICS Gross Internal Area (GIA)",
                      "floor_area" => 1536,
                      "tufa" => 1536,
                      "benchmark" => "General Office",
                      "occupancy_level" => "Standard Occupancy" } }] },
          "or_energy_consumption" =>
             { "electricity" =>
                { "consumption" => 82_812,
                  "start_date" => "2018-11-01",
                  "end_date" => "2019-10-31",
                  "estimate" => 0 },
               "oil" =>
                { "consumption" => 120_344,
                  "start_date" => "2018-11-01",
                  "end_date" => "2019-11-01",
                  "estimate" => 0 } },
          "or_usable_floor_area" =>
             { "ufa_1" => { "name" => "Boiler-room", "floor_area" => 20 }, "total_ufa" => 20 },
          "or_previous_data" =>
             { "previous_rating_1" => { "or" => 67, "ormm" => 12, "oryyyy" => 2018 },
               "previous_rating_2" => { "or" => 66, "ormm" => 12, "oryyyy" => 2017 } },
          "dec_annual_energy_summary" =>
             { "annual_energy_use_electrical" => 54.06,
               "annual_energy_use_fuel_thermal" => 78.35,
               "renewables_fuel_thermal" => 0,
               "renewables_electrical" => 0,
               "typical_thermal_use" => 121.13,
               "typical_electrical_use" => 95 },
          "dec_status" => 0,
          "reason_type" => 1,
          "dec_related_party_disclosure" => 3,
          "this_assessment" =>
             { "nominated_date" => "2019-12-18",
               "energy_rating" => 67,
               "electricity_co2" => 46,
               "heating_co2" => 32,
               "renewables_co2" => 0 },
          "year1_assessment" =>
             { "nominated_date" => "2018-12-01",
               "energy_rating" => 67,
               "electricity_co2" => 45,
               "heating_co2" => 35,
               "renewables_co2" => 0 },
          "year2_assessment" =>
             { "nominated_date" => "2017-12-01",
               "energy_rating" => 66,
               "electricity_co2" => 48,
               "heating_co2" => 28,
               "renewables_co2" => 0 },
          "technical_information" =>
             { "main_heating_fuel" => "Oil",
               "building_environment" => "Heating and Natural Ventilation",
               "floor_area" => 1536,
               "separately_metered_electric_heating" => 0 },
          "ac_questionnaire" =>
             { "ac_present" => "Yes",
               "ac_rated_output" => { "ac_rating_unknown_flag" => 1 },
               "ac_estimated_output" => 1,
               "ac_inspection_commissioned" => 5 },
        }

        actual = use_case.execute xml: dec_rr,
                                  schema_type: "CEPC-NI-8.0.0",
                                  assessment_id: "0000-0000-0000-0000-0000"

        expect(actual).to eq expectation
      end
    end

    context "when importing the DEC recommendation report" do
      it "parses the document in the expected format" do
        expectation = {
          "issue_date" => "2020-11-12",
          "valid_until" => "2027-11-11",
          "report_type" => 2,
          "inspection_date" => "2020-11-12",
          "registration_date" => "2020-11-12",
          "status" => "entered",
          "related_rrn" => "0000-0000-0000-0000-0000",
          "language_code" => 1,
          "scheme_assessor_id" => "TEST000001",
          "location_description" => "5 storey modern office building.",
          "uprn" => "UPRN-000011112222",
          "address_line_1" => "1 Court Lane",
          "address_line_2" => "Made-Up District",
          "address_line_3" => "Fake Village",
          "post_town" => "Anytown",
          "postcode" => "BT7 1AA",
          "is_heritage_site" => "N",
          "property_type" => "General Office",
          "methodology" => "ORCalc",
          "calculation_tool" => "CLG, ORCalc, v4.0.4",
          "inspection_type" => "Physical",
          "output_engine" => "ORGen v4.0.4",
          "short_payback" =>
             [{ "recommendation_code" => "BF6",
                "recommendation" =>
                 "Consider how building fabric air tightness could be improved, for example sealing, draught stripping and closing off unused ventilation openings, chimneys.",
                "co2_impact" => "LOW" }],
          "medium_payback" =>
             [{ "recommendation_code" => "BF22",
                "recommendation" =>
                 "Consider engaging experts to review the condition of the building fabric and propose measures to improve energy performance.  This might include building pressure tests for air tightness and thermography tests for insulation continuity.",
                "co2_impact" => "LOW" }],
          "long_payback" =>
             [{ "recommendation_code" => "AE8",
                "recommendation" => "Consider switching to a less carbon intensive fuel.",
                "co2_impact" => "MEDIUM" },
              { "recommendation_code" => "AE4",
                "recommendation" =>
                 "Consider installing building mounted photovoltaic electricity generating panels.",
                "co2_impact" => "MEDIUM" }],
          "other_payback" =>
             [{ "recommendation_code" => "None",
                "recommendation" => "Ensure offices are not heated above 20C",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "None",
                "recommendation" => "Ensure IT comms server room is not being overcooled",
                "co2_impact" => "LOW" },
              { "recommendation_code" => "None",
                "recommendation" =>
                 "When replacing light fittings consider LED alternatives",
                "co2_impact" => "LOW" }],
          "technical_information" =>
             { "main_heating_fuel" => "Oil",
               "building_environment" => "Heating and Natural Ventilation",
               "floor_area" => 1536 },
          "site_services" =>
             { "service_1" => { "description" => "Oil", "quantity" => 120_344 },
               "service_2" => { "description" => "Electricity", "quantity" => 83_040 },
               "service_3" => { "description" => "Not used", "quantity" => 0 } },
        }

        actual = use_case.execute xml: dec_rr,
                                  schema_type: "CEPC-NI-8.0.0",
                                  assessment_id: "0000-0000-0000-0000-0001"

        expect(actual).to eq expectation
      end
    end
  end

  context "when importing the XML for an AC cert (NI)" do
    let(:ac) { Samples.xml "CEPC-NI-8.0.0", "ac-cert+rr" }

    it "parses the XML for the AC cert to make a structure of the expected format" do
      expectation = {
        "issue_date" => "2020-11-12",
        "report_type" => 6,
        "related_rrn" => "0000-0000-0000-0000-0001",
        "valid_until" => "2025-09-24",
        "inspection_date" => "2020-09-24",
        "registration_date" => "2020-11-15",
        "status" => "entered",
        "language_code" => 1,
        "building_complexity" => "Level 4",
        "scheme_assessor_id" => "TEST000001",
        "uprn" => "UPRN-000011112222",
        "address_line_1" => "The Big Shop",
        "address_line_2" => "The Big Shopping Centre",
        "address_line_3" => "Main Street",
        "post_town" => "Anytown",
        "postcode" => "AN4 5ER",
        "calculation_tool" => "Quidos, AIRS, v2.0",
        "equipment_owner" =>
           { "equipment_owner_name" => "Manager",
             "telephone_number" => 8_445_555_555,
             "organisation_name" => "The Big Shop",
             "registered_address" =>
              { "address_line_1" => "The Big Shop",
                "address_line_2" => "The Big Shopping Centre",
                "address_line_3" => "Main Street",
                "post_town" => "Anytown",
                "postcode" => "AN1 2AA" } },
        "building_name" => "The Big Shop - The Big Shopping Centre",
        "f_gas_compliant_date" => "Not Provided",
        "ac_rated_output" => { "ac_kw_rating" => 750 },
        "random_sampling_flag" => "Y",
        "treated_floor_area" => 6555,
        "ac_system_metered_flag" => 1,
        "refrigerant_charge_total" => 375,
        "ac_sub_systems" =>
           [{ "sub_system_number" => "VOL001/SYS001",
              "sub_system_description" =>
               "Single split non inverter system serves the control room via a wall mounted unit",
              "refrigerant_types" => %w[R407C],
              "sub_system_age" => 2003 },
            { "sub_system_number" => "VOL001/SYS002",
              "sub_system_description" =>
               "Single split non inverter system serves the server room via a wall mounted unit",
              "refrigerant_types" => %w[R407C],
              "sub_system_age" => 2003 },
            { "sub_system_number" => "VOL001/SYS003",
              "sub_system_description" =>
               "VRF packaged system serving staff areas via ducted units / wall mounted unit. Wall mounted unit serving the cash office was inspected upon. Supply and extract AHU extracting stale air supplying tempered fresh air to conditioned areas.",
              "refrigerant_types" => %w[R407C],
              "sub_system_age" => 2003 },
            { "sub_system_number" => "VOL001/SYS004",
              "sub_system_description" =>
               "Seven packaged air to air roof-top packaged air handling units serve the sales areas via ducted diffusers",
              "refrigerant_types" => %w[R407C],
              "sub_system_age" => 2003 }],
      }

      expect(use_case.execute(xml: ac,
                              schema_type: "CEPC-NI-8.0.0",
                              assessment_id: "0000-0000-0000-0000-0000")).to eq expectation
    end
  end
end
