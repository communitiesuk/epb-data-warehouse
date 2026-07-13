require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

describe "Domestic Materialized View" do
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"
  include_context "when saving enum data to lookup tables"

  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }

  let(:date_filtered_results) do
    query_result.select { |i| i["lodgement_date"] >= date_start && i["lodgement_date"] <= date_end }
  end

  let(:filter_args) do
    { query_result:, date_start:, date_end: }
  end

  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_domestic_search ORDER BY certificate_number")
  end
  let(:expected_columns) do
    %w[address address1 address2 address3 built_form certificate_number co2_emiss_curr_per_floor_area co2_emissions_current co2_emissions_potential constituency constituency_label construction_age_band country current_energy_efficiency current_energy_rating energy_consumption_current energy_consumption_potential energy_tariff environment_impact_current environment_impact_potential extension_count fixed_lighting_outlets_count flat_storey_count flat_top_storey floor_description floor_energy_eff floor_env_eff floor_height floor_level glazed_area glazed_type heat_loss_corridor heating_cost_current heating_cost_potential hot_water_cost_current hot_water_cost_potential hot_water_energy_eff hot_water_env_eff hotwater_description inspection_date lighting_cost_current lighting_cost_potential lighting_description lighting_energy_eff lighting_env_eff local_authority local_authority_label lodgement_date lodgement_datetime low_energy_fixed_lighting_outlets_count low_energy_lighting main_fuel main_heating_controls mainheat_description mainheat_energy_eff mainheat_env_eff mainheatc_energy_eff mainheatc_env_eff mainheatcont_description mains_gas_flag mechanical_ventilation multi_glaze_proportion number_habitable_rooms number_heated_rooms number_open_fireplaces photo_supply postcode posttown potential_energy_efficiency potential_energy_rating property_type region report_type roof_description roof_energy_eff roof_env_eff secondheat_description sheating_energy_eff sheating_env_eff solar_water_heating_flag tenure total_floor_area transaction_type unheated_corridor_length uprn uprn_source walls_description walls_energy_eff walls_env_eff wind_turbine_count windows_description windows_energy_eff windows_env_eff]
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    type_of_assessment = "SAP"
    assessment_address_id = "UPRN-000000001245"
    schema_type = "SAP-Schema-19.0.0"
    add_countries

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports")
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0000", assessment_address_id: "RRN-000000001245", schema_type:, type_of_assessment:, different_fields: {
      "postcode": "W6 9ZD", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", assessment_address_id:, schema_type:, type_of_assessment:, different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", assessment_address_id:, schema_type:, type_of_assessment:, different_fields: {
      "postcode": "SW1A 2AA", "energy_rating_current": 50, "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", assessment_address_id:, schema_type:, type_of_assessment:, different_fields: {
      "postcode": "BT1 1AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", assessment_address_id:, schema_type:, type_of_assessment:, different_fields: {
      "registration_date": "2024-12-06T12:00:00.000+00:00", "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode": "W6 9ZD", "country_id": 1, related_rrn: "0000-0000-0000-0000-0055"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "registration_date": "2020-05-06T23:59:59.000+00:00", "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "ML9 9AR", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0008", schema_type: "RdSAP-Schema-21.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "SW1A 2AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0009", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "registration_date": "2021-12-06T00:00:00.000+00:00", "postcode": "SW1A 2AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", assessment_address_id:, schema_type: "SAP-Schema-16.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2020-04-05T12:00:00.000+00:00", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0011", assessment_address_id:, schema_type: "SAP-Schema-16.0", type_of_assessment:, type: "sap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2020-04-05T12:00:00.000+00:00", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0012", assessment_address_id:, schema_type: "SAP-Schema-16.1", type_of_assessment:, type: "sap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2020-04-05T12:00:00.000+00:00", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0013", assessment_address_id:, schema_type: "SAP-Schema-16.1", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2020-04-05T12:00:00.000+00:00", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0014", assessment_address_id:, schema_type: "SAP-Schema-15.0", type_of_assessment:, type: "sap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2022-04-05T12:00:00.000+00:00", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0015", assessment_address_id:, schema_type: "SAP-Schema-15.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "SW10 0AA", "registration_date": "2022-04-05T12:00:00.000+00:00", "country_id": 1
    })

    ActiveRecord::Base.connection.execute("INSERT INTO assessment_search (assessment_id, assessment_type, registration_date, country_id) VALUES ('0000-0000-0000-0000-0003', 'SAP', '2025-08-01', 3)")

    import_look_ups(schema_versions: %w[RdSAP-Schema-21.0.1 RdSAP-Schema-21.0.0 RdSAP-Schema-20.0.0 SAP-Schema-19.0.0 SAP-Schema-16.0 SAP-Schema-16.1 SAP-Schema-15.0])
    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
  end

  it "returns the correct columns" do
    expect(mview_columns("mvw_domestic_search").sort.map(&:downcase)).to eq expected_columns.sort
  end

  it "returns rows for each assessment in England & Wales ordered by certificate_number" do
    expect(date_filtered_results.pluck("certificate_number")).to eq %w[
      0000-0000-0000-0000-0000
      0000-0000-0000-0000-0001
      0000-0000-0000-0000-0002
      0000-0000-0000-0000-0008
      0000-0000-0000-0000-0009
      0000-0000-0000-0000-0014
      0000-0000-0000-0000-0015
    ]
  end

  context "when checking data in the materialized view" do
    let(:expected_sap_1900_data) do
      { "certificate_number" => "0000-0000-0000-0000-0001",
        "address" => "1 Some Street, Some Area, Some County",
        "address1" => "1 Some Street",
        "address2" => "Some Area",
        "address3" => "Some County",
        "postcode" => "SW10 0AA",
        "country" => "England",
        "region" => "E12000007",
        "report_type" => "3",
        "total_floor_area" => "165",
        "built_form" => "Mid-Terrace",
        "inspection_date" => "2022-05-09",
        "environment_impact_current" => "94",
        "energy_consumption_current" => "59",
        "energy_consumption_potential" => "53",
        "environment_impact_potential" => "96",
        "co2_emiss_curr_per_floor_area" => "5.6",
        "co2_emissions_current" => "2.4",
        "co2_emissions_potential" => "1.4",
        "lighting_cost_current" => "123.45",
        "lighting_cost_potential" => "84.23",
        "heating_cost_current" => "365.98",
        "heating_cost_potential" => "250.34",
        "hot_water_cost_current" => "200.4",
        "hot_water_cost_potential" => "180.43",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system, waste water heat recovery",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Average",
        "floor_description" => "Average thermal transmittance 0.12 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "N/A",
        "windows_env_eff" => "Very Good",
        "walls_description" => "Average thermal transmittance 0.18 W/m²K",
        "walls_energy_eff" => "Very Good",
        "walls_env_eff" => "Very Good",
        "secondheat_description" => "Electric heater",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "roof_description" => "Average thermal transmittance 0.13 W/m²K",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "mainheat_description" => "Boiler and radiators, electric",
        "mainheat_energy_eff" => "Average",
        "mainheat_env_eff" => "Poor",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "lighting_description" => "Energy saving bulbs",
        "lighting_energy_eff" => "N/A",
        "lighting_env_eff" => "N/A",
        "main_fuel" => "Electricity: electricity, unspecified tariff",
        "wind_turbine_count" => 1,
        "mechanical_ventilation" => nil,
        "lodgement_date" => "2022-05-09",
        "posttown" => "Whitbury",
        "construction_age_band" => "England and Wales: before 1900",
        "tenure" => "owner-occupied",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "fixed_lighting_outlets_count" => "18",
        "low_energy_fixed_lighting_outlets_count" => "17",
        "current_energy_efficiency" => "72",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "72",
        "potential_energy_rating" => "C",
        "extension_count" => nil,
        "flat_storey_count" => 3,
        "flat_top_storey" => "N",
        "floor_level" => "1",
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "low_energy_lighting" => "94",
        "mains_gas_flag" => nil,
        "number_habitable_rooms" => nil,
        "number_heated_rooms" => nil,
        "number_open_fireplaces" => "0",
        "unheated_corridor_length" => nil,
        "uprn" => 1245,
        "energy_tariff" => "24 hour",
        "floor_height" => "2.8",
        "glazed_type" => nil,
        "photo_supply" => nil,
        "solar_water_heating_flag" => nil,
        "local_authority" => "E09000013",
        "local_authority_label" => "Hammersmith and Fulham",
        "constituency_label" => "Chelsea and Fulham",
        "constituency" => "E14000629",
        "transaction_type" => "Marketed sale",
        "property_type" => "House",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_sap_150_rdsap_data) do
      { "certificate_number" => "0000-0000-0000-0000-0015",
        "address1" => "1 Street Lane",
        "address2" => "Some Street",
        "address3" => "Some Area",
        "address" => "1 Street Lane, Some Street, Some Area",
        "postcode" => "SW10 0AA",
        "inspection_date" => "2012-03-31",
        "uprn" => 1245,
        "environment_impact_potential" => "62",
        "energy_consumption_current" => "299",
        "energy_consumption_potential" => "254",
        "environment_impact_current" => "55",
        "co2_emissions_current" => "3.7",
        "co2_emiss_curr_per_floor_area" => "58",
        "co2_emissions_potential" => "3.1",
        "total_floor_area" => "63",
        "lodgement_date" => "2022-04-05",
        "report_type" => "2",
        "posttown" => "Some Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "58",
        "current_energy_rating" => "D",
        "potential_energy_efficiency" => "63",
        "potential_energy_rating" => "D",
        "extension_count" => "0",
        "number_open_fireplaces" => "1",
        "number_heated_rooms" => "4",
        "number_habitable_rooms" => "4",
        "low_energy_lighting" => "55",
        "low_energy_fixed_lighting_outlets_count" => "6",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => "rental (private)",
        "construction_age_band" => "England and Wales: 1930-1949",
        "built_form" => "Semi-Detached",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing installed before 2002",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => "no corridor",
        "main_fuel" => "mains gas (not community)",
        "unheated_corridor_length" => "10",
        "floor_level" => "3",
        "flat_top_storey" => "Y",
        "flat_storey_count" => 2,
        "mains_gas_flag" => "Y",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "52",
        "lighting_cost_potential" => "36",
        "heating_cost_current" => "578",
        "heating_cost_potential" => "521",
        "hot_water_cost_current" => "132",
        "hot_water_cost_potential" => "104",
        "multi_glaze_proportion" => "65",
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Suspended, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Pitched, 300+ mm loft insulation",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "walls_description" => "Cavity wall, filled cavity",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "Partial double glazing",
        "windows_energy_eff" => "Poor",
        "windows_env_eff" => "Poor",
        "secondheat_description" => "Room heaters, mains gas",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, TRVs and bypass",
        "mainheatc_energy_eff" => "Average",
        "mainheatc_env_eff" => "Average",
        "lighting_description" => "Low energy lighting in 55% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "11",
        "floor_height" => "2.4",
        "main_heating_controls" => "Programmer, TRVs and bypass",
        "local_authority" => "E09000013",
        "local_authority_label" => "Hammersmith and Fulham",
        "constituency_label" => "Chelsea and Fulham",
        "constituency" => "E14000629",
        "country" => "England",
        "region" => "E12000007",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_sap_160_rdsap_data) do
      { "certificate_number" => "0000-0000-0000-0000-0010",
        "address1" => "11, Street Road",
        "address2" => nil,
        "address3" => nil,
        "address" => "11, Street Road",
        "postcode" => "SW10 0AA",
        "inspection_date" => "2012-09-27",
        "uprn" => 1245,
        "environment_impact_potential" => "86",
        "energy_consumption_current" => "144",
        "energy_consumption_potential" => "64",
        "environment_impact_current" => "72",
        "co2_emissions_current" => "2.9",
        "co2_emiss_curr_per_floor_area" => "28",
        "co2_emissions_potential" => "1.4",
        "total_floor_area" => "107",
        "lodgement_date" => "2020-04-05",
        "report_type" => "2",
        "posttown" => "Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "73",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "86",
        "potential_energy_rating" => "B",
        "extension_count" => "1",
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => "5",
        "number_habitable_rooms" => "5",
        "low_energy_lighting" => "67",
        "low_energy_fixed_lighting_outlets_count" => "10",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "Bungalow",
        "transaction_type" => "marketed sale",
        "construction_age_band" => "England and Wales: 1967-1975",
        "built_form" => "Detached",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing installed during or after 2002",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => nil,
        "main_fuel" => "mains gas (not community)",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => "Y",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "73",
        "lighting_cost_potential" => "55",
        "heating_cost_current" => "494",
        "heating_cost_potential" => "428",
        "hot_water_cost_current" => "90",
        "hot_water_cost_potential" => "64",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Solid, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Pitched, 300+ mm loft insulation",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "walls_description" => "Cavity wall, filled cavity",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Good",
        "windows_env_eff" => "Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 67% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "15",
        "floor_height" => "2.33",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => "E09000013",
        "local_authority_label" => "Hammersmith and Fulham",
        "constituency_label" => "Chelsea and Fulham",
        "constituency" => "E14000629",
        "country" => "England",
        "region" => "E12000007",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_sap_150_sap_data) do
      {
        "address" => "Flat 1, Block of Flats, Some Street",
        "address1" => "Flat 1",
        "address2" => "Block of Flats",
        "address3" => "Some Street",
        "built_form" => "Detached",
        "certificate_number" => "0000-0000-0000-0000-0014",
        "co2_emiss_curr_per_floor_area" => "22",
        "co2_emissions_current" => "7.1",
        "co2_emissions_potential" => "6.9",
        "constituency" => "E14000629",
        "constituency_label" => "Chelsea and Fulham",
        "construction_age_band" => "2011",
        "country" => "England",
        "current_energy_efficiency" => "82",
        "current_energy_rating" => "B",
        "energy_consumption_current" => "126",
        "energy_consumption_potential" => "123",
        "energy_tariff" => "off-peak 10 hour",
        "environment_impact_current" => "74",
        "environment_impact_potential" => "75",
        "extension_count" => nil, # RdSAP only
        "fixed_lighting_outlets_count" => "10",
        "flat_storey_count" => 1,
        "flat_top_storey" => "Y",
        "floor_description" => "(other premises below)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "floor_height" => "3.3",
        "floor_level" => "3",
        "glazed_area" => nil, # RdSAP only
        "glazed_type" => nil, # RdSAP only
        "heat_loss_corridor" => nil, # RdSAP only
        "heating_cost_current" => "787",
        "heating_cost_potential" => "796",
        "hot_water_cost_current" => "92",
        "hot_water_cost_potential" => "92",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "hotwater_description" => "From main system",
        "inspection_date" => "2011-11-15",
        "lighting_cost_current" => "150",
        "lighting_cost_potential" => "88",
        "lighting_description" => "Low energy lighting in 30% of fixed outlets",
        "lighting_energy_eff" => "Average",
        "lighting_env_eff" => "Average",
        "local_authority" => "E09000013",
        "local_authority_label" => "Hammersmith and Fulham",
        "lodgement_date" => "2022-04-05",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "low_energy_fixed_lighting_outlets_count" => "3",
        "low_energy_lighting" => "30",
        "main_fuel" => "Electricity: electricity, unspecified tariff",
        "main_heating_controls" => "Programmer and at least two room thermostats",
        "mainheat_description" => "Air source heat pump, warm air, electric, Electric underfloor heating",
        "mainheat_energy_eff" => "Very Good",
        "mainheat_env_eff" => "Good",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "mainheatcont_description" => "Programmer and at least two room thermostats",
        "mains_gas_flag" => nil, # RdSAP only
        "mechanical_ventilation" => nil, # RdSAP only
        "multi_glaze_proportion" => nil, # RdSAP only
        "number_habitable_rooms" => nil, # RdSAP only
        "number_heated_rooms" => nil, # RdSAP only
        "number_open_fireplaces" => "0",
        "photo_supply" => nil, # RdSAP only
        "postcode" => "SW10 0AA",
        "posttown" => "Some Town",
        "potential_energy_efficiency" => "83",
        "potential_energy_rating" => "B",
        "property_type" => "Maisonette",
        "region" => "E12000007",
        "report_type" => "3",
        "roof_description" => "Average thermal transmittance 0.15 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "solar_water_heating_flag" => nil, # RdSAP only
        "tenure" => nil, # Not in schema
        "total_floor_area" => "316",
        "transaction_type" => "new dwelling",
        "unheated_corridor_length" => nil, # RdSAP only
        "uprn" => 1245,
        "uprn_source" => "Energy Assessor",
        "walls_description" => "Average thermal transmittance 0.35 W/m²K",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "wind_turbine_count" => 0,
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
      }
    end

    let(:expected_sap_160_sap_data) do
      { "certificate_number" => "0000-0000-0000-0000-0011",
        "address1" => "28, Place Drive",
        "address2" => nil,
        "address3" => nil,
        "address" => "28, Place Drive",
        "postcode" => "SW10 0AA",
        "inspection_date" => "2012-09-29",
        "uprn" => 1245,
        "environment_impact_potential" => "87",
        "energy_consumption_current" => "87",
        "energy_consumption_potential" => "82",
        "environment_impact_current" => "86",
        "co2_emissions_current" => "1.3",
        "co2_emiss_curr_per_floor_area" => "16",
        "co2_emissions_potential" => "1.3",
        "total_floor_area" => "80",
        "lodgement_date" => "2020-04-05",
        "report_type" => "3",
        "posttown" => "Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "82",
        "current_energy_rating" => "B",
        "potential_energy_efficiency" => "83",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "57",
        "low_energy_fixed_lighting_outlets_count" => "4",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => "Flat",
        "transaction_type" => "new dwelling",
        "construction_age_band" => "2011",
        "built_form" => "Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Gas: mains gas",
        "unheated_corridor_length" => nil,
        "floor_level" => "2",
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "66",
        "lighting_cost_potential" => "46",
        "heating_cost_current" => "213",
        "heating_cost_potential" => "215",
        "hot_water_cost_current" => "94",
        "hot_water_cost_potential" => "94",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Average thermal transmittance 0.25 W/m²K",
        "floor_energy_eff" => "Good",
        "floor_env_eff" => "Good",
        "roof_description" => "(other premises above)",
        "roof_energy_eff" => "N/A",
        "roof_env_eff" => "N/A",
        "walls_description" => "Average thermal transmittance 0.34 W/m²K",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Good",
        "windows_env_eff" => "Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 57% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "7",
        "floor_height" => "2.32",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => "E09000013",
        "local_authority_label" => "Hammersmith and Fulham",
        "constituency_label" => "Chelsea and Fulham",
        "constituency" => "E14000629",
        "country" => "England",
        "region" => "E12000007",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_sap_161_sap_data) do
      expected_sap_160_sap_data.merge(
        "certificate_number" => "0000-0000-0000-0000-0012",
        "built_form" => "Mid-Terrace",
        "co2_emiss_curr_per_floor_area" => "22",
        "co2_emissions_potential" => "1.2",
        "construction_age_band" => "2012",
        "current_energy_efficiency" => "79",
        "current_energy_rating" => "C",
        "energy_consumption_current" => "119",
        "energy_consumption_potential" => "110",
        "environment_impact_current" => "83",
        "environment_impact_potential" => "84",
        "fixed_lighting_outlets_count" => "9",
        "flat_storey_count" => 2,
        "floor_description" => "Average thermal transmittance 0.18 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "floor_height" => "2.37",
        "floor_level" => nil,
        "heating_cost_current" => "236",
        "heating_cost_potential" => "240",
        "hot_water_cost_current" => "76",
        "hot_water_cost_potential" => "76",
        "inspection_date" => "2013-01-12",
        "lighting_cost_potential" => "39",
        "lighting_description" => "Low energy lighting in 33% of fixed outlets",
        "lighting_energy_eff" => "Average",
        "lighting_env_eff" => "Average",
        "low_energy_fixed_lighting_outlets_count" => "3",
        "low_energy_lighting" => "33",
        "potential_energy_efficiency" => "80",
        "potential_energy_rating" => "C",
        "property_type" => "House",
        "roof_description" => "Average thermal transmittance 0.15 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "total_floor_area" => "59",
        "transaction_type" => "New dwelling",
        "walls_description" => "Average thermal transmittance 0.30 W/m²K",
      )
    end

    let(:expected_sap_161_rdsap_data) do
      expected_sap_160_sap_data.merge(
        "certificate_number" => "0000-0000-0000-0000-0013",
        "address" => "15, What the Dickens Road",
        "address1" => "15, What the Dickens Road",
        "built_form" => "Mid-Terrace",
        "co2_emiss_curr_per_floor_area" => "47",
        "co2_emissions_current" => "3.4",
        "co2_emissions_potential" => "1.0",
        "construction_age_band" => "England and Wales: 1930-1949",
        "current_energy_efficiency" => "61",
        "current_energy_rating" => "D",
        "energy_consumption_current" => "244",
        "energy_consumption_potential" => "66",
        "energy_tariff" => "Single",
        "environment_impact_current" => "59",
        "environment_impact_potential" => "86",
        "extension_count" => "1",
        "fixed_lighting_outlets_count" => "11",
        "flat_storey_count" => 2,
        "floor_description" => "Suspended, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "floor_height" => "2.43",
        "floor_level" => nil,
        "glazed_area" => "Normal",
        "glazed_type" => "double glazing, unknown install date",
        "heating_cost_current" => "546",
        "heating_cost_potential" => "378",
        "hot_water_cost_current" => "127",
        "hot_water_cost_potential" => "68",
        "inspection_date" => "2013-01-09",
        "lighting_cost_current" => "69",
        "lighting_cost_potential" => "42",
        "lighting_description" => "Low energy lighting in 36% of fixed outlets",
        "lighting_energy_eff" => "Average",
        "lighting_env_eff" => "Average",
        "low_energy_fixed_lighting_outlets_count" => "4",
        "low_energy_lighting" => "36",
        "main_fuel" => "mains gas (not community)",
        "main_heating_controls" => "Room thermostat only",
        "mainheatc_energy_eff" => "Poor",
        "mainheatc_env_eff" => "Poor",
        "mainheatcont_description" => "Room thermostat only",
        "mains_gas_flag" => "Y",
        "mechanical_ventilation" => "natural",
        "multi_glaze_proportion" => "100",
        "number_habitable_rooms" => "5",
        "number_heated_rooms" => "5",
        "photo_supply" => "0",
        "potential_energy_efficiency" => "85",
        "potential_energy_rating" => "B",
        "property_type" => "House",
        "report_type" => "2",
        "roof_description" => "Pitched, 300+ mm loft insulation",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "solar_water_heating_flag" => "N",
        "total_floor_area" => "72",
        "tenure" => "Rented (social)",
        "transaction_type" => "Rental",
        "walls_description" => "Cavity wall, filled cavity",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Average",
        "windows_env_eff" => "Average",
      )
    end

    let(:expected_rdsap_2000_data) do
      expected_sap_1900_data.merge(
        "address" => "1 Some Street",
        "address2" => nil,
        "address3" => nil,
        "report_type" => "2",
        "built_form" => "Semi-Detached",
        "co2_emiss_curr_per_floor_area" => "20",
        "environment_impact_current" => "52",
        "environment_impact_potential" => "74",
        "extension_count" => "0",
        "construction_age_band" => "England and Wales: 2007-2011",
        "current_energy_efficiency" => "50",
        "current_energy_rating" => "E",
        "energy_consumption_current" => "230",
        "energy_consumption_potential" => "88",
        "energy_tariff" => "Single",
        "fixed_lighting_outlets_count" => "16",
        "flat_storey_count" => 2,
        "flat_top_storey" => "N",
        "floor_description" => "Suspended, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "floor_level" => "1",
        "floor_height" => "2.45",
        "glazed_area" => "Normal",
        "glazed_type" => "double glazing installed during or after 2002",
        "photo_supply" => "50",
        "solar_water_heating_flag" => "N",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "heating_cost_current" => "365.98",
        "heating_cost_potential" => "250.34",
        "heat_loss_corridor" => "unheated corridor",
        "hot_water_cost_current" => "200.4",
        "hot_water_cost_potential" => "180.43",
        "hotwater_description" => "From main system",
        "hot_water_env_eff" => "Good",
        "inspection_date" => "2020-05-04",
        "lighting_cost_current" => "123.45",
        "lighting_cost_potential" => "84.23",
        "lighting_description" => "Low energy lighting in 50% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "lodgement_date" => "2020-05-06",
        "low_energy_lighting" => "100",
        "low_energy_fixed_lighting_outlets_count" => "16",
        "main_fuel" => "mains gas (not community)",
        "mains_gas_flag" => "Y",
        "mainheat_description" => "Boiler and radiators, anthracite, Boiler and radiators, mains gas",
        "mainheat_env_eff" => "Very Poor",
        "mechanical_ventilation" => "natural",
        "multi_glaze_proportion" => "100",
        "number_habitable_rooms" => "5",
        "number_heated_rooms" => "5",
        "number_open_fireplaces" => "0",
        "roof_description" => "Pitched, 25 mm loft insulation",
        "roof_energy_eff" => "Poor",
        "roof_env_eff" => "Poor",
        "certificate_number" => "0000-0000-0000-0000-0006",
        "secondheat_description" => "Room heaters, electric",
        "total_floor_area" => "55",
        "uprn" => nil,
        "unheated_corridor_length" => "10",
        "walls_description" => "Solid brick, as built, no insulation (assumed)",
        "walls_energy_eff" => "Very Poor",
        "walls_env_eff" => "Very Poor",
        "wind_turbine_count" => 0,
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Average",
        "windows_env_eff" => "Average",
        "local_authority" => "E09000013",
        "uprn_source" => nil,
      )
    end

    let(:expected_rdsap_2100_data) do
      expected_rdsap_2000_data.merge(
        "certificate_number" => "0000-0000-0000-0000-0008",
        "construction_age_band" => "England and Wales: 2022 onwards",
        "fixed_lighting_outlets_count" => "36",
        "glazed_area" => nil,
        "glazed_type" => nil,
        "inspection_date" => "2023-12-01",
        "lodgement_date" => "2023-12-01",
        "low_energy_fixed_lighting_outlets_count" => "31",
        "low_energy_lighting" => "86",
        "mechanical_ventilation" => "positive input from outside",
        "number_open_fireplaces" => "1",
        "photo_supply" => "0",
        "transaction_type" => "Grant scheme",
        "postcode" => "SW1A 2AA",
        "constituency" => "E14001172",
        "constituency_label" => "Cities of London and Westminster",
        "local_authority" => "E09000033",
        "local_authority_label" => "Westminster",
      )
    end

    let(:expected_rdsap_2101_data) do
      expected_rdsap_2000_data.merge(
        "certificate_number" => "0000-0000-0000-0000-0009",
        "construction_age_band" => "England and Wales: 2022 onwards",
        "fixed_lighting_outlets_count" => "31",
        "glazed_area" => nil,
        "glazed_type" => nil,
        "inspection_date" => "2025-04-04",
        "lodgement_date" => "2021-12-06",
        "low_energy_fixed_lighting_outlets_count" => "31",
        "low_energy_lighting" => "100",
        "mechanical_ventilation" => "positive input from outside",
        "number_open_fireplaces" => "1",
        "photo_supply" => "0",
        "transaction_type" => "Grant scheme",
        "unheated_corridor_length" => "10",
        "postcode" => "SW1A 2AA",
        "constituency" => "E14001172",
        "constituency_label" => "Cities of London and Westminster",
        "local_authority" => "E09000033",
        "local_authority_label" => "Westminster",
      )
    end

    it "returns a row with the required data for SAP 15.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0014" }
      expect(result).to eq expected_sap_150_sap_data
    end

    it "returns a row with the required data for SAP 15.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0015" }
      expect(result).to eq expected_sap_150_rdsap_data
    end

    it "returns a row with the required data for SAP 16.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0010" }
      expect(result).to eq expected_sap_160_rdsap_data
    end

    it "returns a row with the required data for SAP 16.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0011" }
      expect(result).to eq expected_sap_160_sap_data
    end

    it "returns a row with the required data for SAP 16.1 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0012" }
      expect(result).to eq expected_sap_161_sap_data
    end

    it "returns a row with the required data for SAP 16.1 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0013" }
      expect(result).to eq expected_sap_161_rdsap_data
    end

    it "returns a row with the required data for SAP 19.0.0" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0001" }
      expect(result).to eq expected_sap_1900_data
    end

    it "returns a row with the required data for RdSAP 20.0.0" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }
      expect(result).to eq expected_rdsap_2000_data
    end

    it "returns a row with the required data for RdSAP 21.0.0" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0008" }
      expect(result).to eq expected_rdsap_2100_data
    end

    it "returns a row with the required data for RdSAP 21.0.1" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0009" }
      expect(result).to eq expected_rdsap_2101_data
    end
  end

  context "when an assessment has a no value saved into the assessment_address_id attribute" do
    it "returns a nil value for the uprn" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0000" }["uprn"]).to be_nil
    end
  end

  context "when an assessment is from NI" do
    let(:ni_assessment_id) { "0000-0000-0000-0000-0003" }

    it "does not include the assessment in the results" do
      expect(query_result.find { |i| i["certificate_number"] == ni_assessment_id }).to be_nil
    end
  end
end
