require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

describe "Domestic NI Materialized View" do
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
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_domestic_ni_search ORDER BY certificate_number")
  end

  let(:expected_columns) do
    %w[address address1 address2 address3 built_form certificate_number co2_emiss_curr_per_floor_area co2_emissions_current co2_emissions_potential constituency constituency_label construction_age_band country current_energy_efficiency current_energy_rating energy_consumption_current energy_consumption_potential energy_tariff environment_impact_current environment_impact_potential extension_count fixed_lighting_outlets_count flat_storey_count flat_top_storey floor_description floor_energy_eff floor_env_eff floor_height floor_level glazed_area glazed_type heat_loss_corridor heating_cost_current heating_cost_potential hot_water_cost_current hot_water_cost_potential hot_water_energy_eff hot_water_env_eff hotwater_description inspection_date lighting_cost_current lighting_cost_potential lighting_description lighting_energy_eff lighting_env_eff local_authority local_authority_label lodgement_date lodgement_datetime low_energy_fixed_lighting_outlets_count low_energy_lighting main_fuel main_heating_controls mainheat_description mainheat_energy_eff mainheat_env_eff mainheatc_energy_eff mainheatc_env_eff mainheatcont_description mains_gas_flag mechanical_ventilation multi_glaze_proportion number_habitable_rooms number_heated_rooms number_open_fireplaces photo_supply postcode posttown potential_energy_efficiency potential_energy_rating property_type region report_type roof_description roof_energy_eff roof_env_eff secondheat_description sheating_energy_eff sheating_env_eff solar_water_heating_flag tenure total_floor_area transaction_type unheated_corridor_length uprn uprn_source walls_description walls_energy_eff walls_env_eff wind_turbine_count windows_description windows_energy_eff windows_env_eff]
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    type_of_assessment = "SAP"
    assessment_address_id = "UPRN-000000001245"
    add_countries

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports")

    # England/Wales assessments - should NOT be in NIR results
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", assessment_address_id:, schema_type: "SAP-Schema-19.0.0", type_of_assessment:, different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", assessment_address_id:, schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })

    # Northern Ireland assessments - SHOULD be in results
    # SAP-Schema-NI-11.2 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0112", assessment_address_id:, schema_type: "SAP-Schema-NI-11.2", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT1 1AA", "registration_date": "2022-04-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-11.2 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1112", assessment_address_id:, schema_type: "SAP-Schema-NI-11.2", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT1 1AA", "registration_date": "2022-04-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-12.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0120", assessment_address_id:, schema_type: "SAP-Schema-NI-12.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT2 8AA", "registration_date": "2022-05-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-12.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1120", assessment_address_id:, schema_type: "SAP-Schema-NI-12.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT2 8AA", "registration_date": "2022-05-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-13.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0130", assessment_address_id:, schema_type: "SAP-Schema-NI-13.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT3 9AA", "registration_date": "2022-06-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-13.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1130", assessment_address_id:, schema_type: "SAP-Schema-NI-13.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT3 9AA", "registration_date": "2022-06-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-14.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0140", assessment_address_id:, schema_type: "SAP-Schema-NI-14.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT4 1AA", "registration_date": "2022-07-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-14.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1140", assessment_address_id:, schema_type: "SAP-Schema-NI-14.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT4 1AA", "registration_date": "2022-07-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-14.1 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0141", assessment_address_id:, schema_type: "SAP-Schema-NI-14.1", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT5 6AA", "registration_date": "2022-08-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-14.1 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1141", assessment_address_id:, schema_type: "SAP-Schema-NI-14.1", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT5 6AA", "registration_date": "2022-08-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-14.2 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0142", assessment_address_id:, schema_type: "SAP-Schema-NI-14.2", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT6 8AA", "registration_date": "2022-09-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-14.2 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1142", assessment_address_id:, schema_type: "SAP-Schema-NI-14.2", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT6 8AA", "registration_date": "2022-09-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-15.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0150", assessment_address_id:, schema_type: "SAP-Schema-NI-15.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT7 1AA", "registration_date": "2022-10-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-15.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1150", assessment_address_id:, schema_type: "SAP-Schema-NI-15.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT7 1AA", "registration_date": "2022-10-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-16.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0160", assessment_address_id:, schema_type: "SAP-Schema-NI-16.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT8 6AA", "registration_date": "2022-11-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-16.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1160", assessment_address_id:, schema_type: "SAP-Schema-NI-16.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT8 6AA", "registration_date": "2022-11-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-16.1 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0161", assessment_address_id:, schema_type: "SAP-Schema-NI-16.1", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT9 5AA", "registration_date": "2022-12-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-16.1 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1161", assessment_address_id:, schema_type: "SAP-Schema-NI-16.1", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT9 5AA", "registration_date": "2022-12-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-17.0 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0170", assessment_address_id:, schema_type: "SAP-Schema-NI-17.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "registration_date": "2023-01-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-17.0 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1170", assessment_address_id:, schema_type: "SAP-Schema-NI-17.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT10 0AA", "registration_date": "2023-01-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-17.1 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0171", assessment_address_id:, schema_type: "SAP-Schema-NI-17.1", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT11 9AA", "registration_date": "2023-02-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-17.1 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1171", assessment_address_id:, schema_type: "SAP-Schema-NI-17.1", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT11 9AA", "registration_date": "2023-02-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-17.2 - SAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0172", assessment_address_id:, schema_type: "SAP-Schema-NI-17.2", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT12 4AA", "registration_date": "2023-03-05T12:00:00.000+00:00", "country_id": 3
    })
    # SAP-Schema-NI-17.2 - RdSAP
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1172", assessment_address_id:, schema_type: "SAP-Schema-NI-17.2", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT12 4AA", "registration_date": "2023-03-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-17.3 - RdSAP (RdSAP only schema)
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1173", assessment_address_id:, schema_type: "SAP-Schema-NI-17.3", type_of_assessment: "SAP", different_fields: {
      "postcode": "BT13 3AA", "registration_date": "2023-04-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-17.4 - RdSAP (RdSAP only schema)
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1174", assessment_address_id:, schema_type: "SAP-Schema-NI-17.4", type_of_assessment: "SAP", different_fields: {
      "postcode": "BT14 7AA", "registration_date": "2023-05-05T12:00:00.000+00:00", "country_id": 3
    })

    # SAP-Schema-NI-18.0.0 - RdSAP (RdSAP only schema)
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1180", assessment_address_id:, schema_type: "SAP-Schema-NI-18.0.0", type_of_assessment: "SAP", different_fields: {
      "postcode": "BT15 2AA", "registration_date": "2023-06-05T12:00:00.000+00:00", "country_id": 3
    })

    # Update import_look_ups to include all schemas
    import_look_ups(schema_versions: %w[
      SAP-Schema-NI-11.2
      SAP-Schema-NI-12.0
      SAP-Schema-NI-13.0
      SAP-Schema-NI-14.0
      SAP-Schema-NI-14.1
      SAP-Schema-NI-14.2
      SAP-Schema-NI-15.0
      SAP-Schema-NI-16.0
      SAP-Schema-NI-16.1
      SAP-Schema-NI-17.0
      SAP-Schema-NI-17.1
      SAP-Schema-NI-17.2
      RdSAP-Schema-NI-17.3
      RdSAP-Schema-NI-17.4
      RdSAP-Schema-NI-18.0.0
    ])

    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_ni_search")
  end

  it "returns the correct columns" do
    expect(mview_columns("mvw_domestic_ni_search").sort.map(&:downcase)).to eq expected_columns.sort
  end

  it "returns rows for each NI assessment ordered by certificate_number" do
    expect(date_filtered_results.pluck("certificate_number")).to eq %w[
      1000-0000-0000-0000-0112
      1000-0000-0000-0000-0120
      1000-0000-0000-0000-0130
      1000-0000-0000-0000-0140
      1000-0000-0000-0000-0141
      1000-0000-0000-0000-0142
      1000-0000-0000-0000-0150
      1000-0000-0000-0000-0160
      1000-0000-0000-0000-0161
      1000-0000-0000-0000-0170
      1000-0000-0000-0000-0171
      1000-0000-0000-0000-0172
      1000-0000-0000-0000-1112
      1000-0000-0000-0000-1120
      1000-0000-0000-0000-1130
      1000-0000-0000-0000-1140
      1000-0000-0000-0000-1141
      1000-0000-0000-0000-1142
      1000-0000-0000-0000-1150
      1000-0000-0000-0000-1160
      1000-0000-0000-0000-1161
      1000-0000-0000-0000-1170
      1000-0000-0000-0000-1171
      1000-0000-0000-0000-1172
      1000-0000-0000-0000-1173
      1000-0000-0000-0000-1174
      1000-0000-0000-0000-1180
    ]
  end

  context "when checking data in the materialized view" do
    let(:expected_ni_120_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0120",
        "address1" => "1 Some Street",
        "address2" => "Some Area",
        "address3" => "Some County",
        "address" => "1 Some Street, Some Area, Some County",
        "postcode" => "BT2 8AA",
        "inspection_date" => "2020-05-04",
        "uprn" => 1245,
        "environment_impact_potential" => "93",
        "energy_consumption_current" => "230",
        "energy_consumption_potential" => "88",
        "environment_impact_current" => "52",
        "co2_emissions_current" => "2.4",
        "co2_emiss_curr_per_floor_area" => "20",
        "co2_emissions_potential" => "1.4",
        "total_floor_area" => nil,
        "lodgement_date" => "2022-05-05",
        "report_type" => "3",
        "posttown" => "Whitbury",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "50",
        "current_energy_rating" => "E",
        "potential_energy_efficiency" => "72",
        "potential_energy_rating" => "C",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "100",
        "low_energy_fixed_lighting_outlets_count" => "8",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => "Flat",
        "transaction_type" => "marketed sale",
        "construction_age_band" => "1750",
        "built_form" => "Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Electricity: electricity sold to grid",
        "unheated_corridor_length" => nil,
        "floor_level" => "1",
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "123.45",
        "lighting_cost_potential" => "84.23",
        "heating_cost_current" => "365.98",
        "heating_cost_potential" => "250.34",
        "hot_water_cost_current" => "200.4",
        "hot_water_cost_potential" => "180.43",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "Gas boiler",
        "hot_water_energy_eff" => "N/A",
        "hot_water_env_eff" => "N/A",
        "floor_description" => "Tiled floor",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Slate roof",
        "roof_energy_eff" => "N/A",
        "roof_env_eff" => "N/A",
        "walls_description" => "Brick walls",
        "walls_energy_eff" => "N/A",
        "walls_env_eff" => "N/A",
        "windows_description" => "Glass window",
        "windows_energy_eff" => "N/A",
        "windows_env_eff" => "N/A",
        "secondheat_description" => "Electric heater",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Gas boiler",
        "mainheat_energy_eff" => "N/A",
        "mainheat_env_eff" => "N/A",
        "mainheatcont_description" => "Thermostat",
        "mainheatc_energy_eff" => "N/A",
        "mainheatc_env_eff" => "N/A",
        "lighting_description" => "Energy saving bulbs",
        "lighting_energy_eff" => "N/A",
        "lighting_env_eff" => "N/A",
        "fixed_lighting_outlets_count" => "8",
        "floor_height" => "2.4",
        "main_heating_controls" => "Thermostat",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_120_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1120",
        "address1" => "1 Some Street",
        "address2" => "Some Area",
        "address3" => "Some County",
        "address" => "1 Some Street, Some Area, Some County",
        "postcode" => "BT2 8AA",
        "inspection_date" => "2020-05-04",
        "uprn" => 1245,
        "environment_impact_potential" => "70",
        "energy_consumption_current" => "230",
        "energy_consumption_potential" => "88",
        "environment_impact_current" => "52",
        "co2_emissions_current" => "2.4",
        "co2_emiss_curr_per_floor_area" => "56",
        "co2_emissions_potential" => "1.4",
        "total_floor_area" => nil,
        "lodgement_date" => "2022-05-05",
        "report_type" => "2",
        "posttown" => "Whitbury",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "50",
        "current_energy_rating" => "E",
        "potential_energy_efficiency" => "72",
        "potential_energy_rating" => "C",
        "extension_count" => "1",
        "number_open_fireplaces" => "2",
        "number_heated_rooms" => "5",
        "number_habitable_rooms" => "5",
        "low_energy_lighting" => "82",
        "low_energy_fixed_lighting_outlets_count" => nil,
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => "not sale or rental",
        "construction_age_band" => "Pre-1900",
        "built_form" => "End-Terrace",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing installed during or after 2002",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => "unheated corridor",
        "main_fuel" => nil,
        "unheated_corridor_length" => "10.34",
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => "Y",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "123.45",
        "lighting_cost_potential" => "84.23",
        "heating_cost_current" => "365.98",
        "heating_cost_potential" => "250.34",
        "hot_water_cost_current" => "200.4",
        "hot_water_cost_potential" => "180.43",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "Gas boiler",
        "hot_water_energy_eff" => "N/A",
        "hot_water_env_eff" => "N/A",
        "floor_description" => "Tiled floor",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Slate roof",
        "roof_energy_eff" => "N/A",
        "roof_env_eff" => "N/A",
        "walls_description" => "Brick walls",
        "walls_energy_eff" => "N/A",
        "walls_env_eff" => "N/A",
        "windows_description" => "Glass window",
        "windows_energy_eff" => "N/A",
        "windows_env_eff" => "N/A",
        "secondheat_description" => "Electric heater",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Gas boiler",
        "mainheat_energy_eff" => "N/A",
        "mainheat_env_eff" => "N/A",
        "mainheatcont_description" => "Thermostat",
        "mainheatc_energy_eff" => "N/A",
        "mainheatc_env_eff" => "N/A",
        "lighting_description" => "Energy saving bulbs",
        "lighting_energy_eff" => "N/A",
        "lighting_env_eff" => "N/A",
        "fixed_lighting_outlets_count" => nil,
        "floor_height" => "2.45",
        "main_heating_controls" => "Thermostat",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_130_sap_data) do
      expected_ni_120_sap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-0130",
        "postcode" => "BT3 9AA",
        "lodgement_date" => "2022-06-05",
        "total_floor_area" => "69",
      )
    end

    let(:expected_ni_130_rdsap_data) do
      expected_ni_120_rdsap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-1130",
        "postcode" => "BT3 9AA",
        "lodgement_date" => "2022-06-05",
        "heat_loss_corridor" => nil,
        "construction_age_band" => "England and Wales: before 1900",
        "total_floor_area" => "69",
        "unheated_corridor_length" => nil,
      )
    end

    let(:expected_ni_140_sap_data) do
      expected_ni_120_sap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-0140",
        "postcode" => "BT4 1AA",
        "lodgement_date" => "2022-07-05",
        "total_floor_area" => "69",
        "number_open_fireplaces" => nil,
      )
    end

    let(:expected_ni_140_rdsap_data) do
      expected_ni_120_sap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-1140",
        "postcode" => "BT4 1AA",
        "lodgement_date" => "2022-07-05",
        "total_floor_area" => "69",
        "construction_age_band" => "England and Wales: before 1900",
        "mains_gas_flag" => "Y",
        "mechanical_ventilation" => "natural",
        "multi_glaze_proportion" => "100",
        "number_habitable_rooms" => "5",
        "number_heated_rooms" => "5",
        "number_open_fireplaces" => "2",
        "photo_supply" => "0",
        "property_type" => "House",
        "report_type" => "2",
        "solar_water_heating_flag" => "N",
        "transaction_type" => "not sale or rental",
        "built_form" => "End-Terrace",
        "co2_emiss_curr_per_floor_area" => "56",
        "energy_tariff" => "Single",
        "environment_impact_potential" => "70",
        "extension_count" => "1",
        "fixed_lighting_outlets_count" => nil,
        "flat_storey_count" => 2,
        "floor_height" => "2.45",
        "floor_level" => nil,
        "glazed_area" => "Normal",
        "glazed_type" => "double glazing installed during or after 2002",
        "low_energy_fixed_lighting_outlets_count" => nil,
        "low_energy_lighting" => "82",
        "main_fuel" => nil,
      )
    end

    let(:expected_ni_141_sap_data) do
      expected_ni_140_sap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-0141",
        "postcode" => "BT5 6AA",
        "lodgement_date" => "2022-08-05",
        "number_open_fireplaces" => nil,
      )
    end

    let(:expected_ni_141_rdsap_data) do
      expected_ni_140_rdsap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-1141",
        "postcode" => "BT5 6AA",
        "lodgement_date" => "2022-08-05",
        "total_floor_area" => "69",
      )
    end

    let(:expected_ni_142_sap_data) do
      expected_ni_120_sap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-0142",
        "postcode" => "BT6 8AA",
        "lodgement_date" => "2022-09-05",
        "total_floor_area" => "69",
        "property_type" => "Flat",
        "built_form" => "Detached",
        "floor_level" => "1",
        "flat_storey_count" => 1,
        "low_energy_lighting" => "100",
        "transaction_type" => "marketed sale",
      )
    end

    let(:expected_ni_142_rdsap_data) do
      expected_ni_140_rdsap_data.merge(
        "certificate_number" => "1000-0000-0000-0000-1142",
        "postcode" => "BT6 8AA",
        "lodgement_date" => "2022-09-05",
      )
    end

    let(:expected_ni_150_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0150",
        "address1" => "3, Street Close",
        "address2" => nil,
        "address3" => nil,
        "address" => "3, Street Close",
        "postcode" => "BT7 1AA",
        "inspection_date" => "2012-03-30",
        "uprn" => 1245,
        "environment_impact_potential" => "80",
        "energy_consumption_current" => "124",
        "energy_consumption_potential" => "118",
        "environment_impact_current" => "79",
        "co2_emissions_current" => "2.8",
        "co2_emiss_curr_per_floor_area" => "20",
        "co2_emissions_potential" => "2.7",
        "total_floor_area" => "136",
        "lodgement_date" => "2022-10-05",
        "report_type" => "3",
        "posttown" => "FERGUS",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "81",
        "current_energy_rating" => "B",
        "potential_energy_efficiency" => "82",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "38",
        "low_energy_fixed_lighting_outlets_count" => nil,
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => nil,
        "construction_age_band" => "2012",
        "built_form" => "Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Gas: mains gas",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "125",
        "lighting_cost_potential" => "77",
        "heating_cost_current" => "401",
        "heating_cost_potential" => "408",
        "hot_water_cost_current" => "132",
        "hot_water_cost_potential" => "132",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Very Good",
        "hot_water_env_eff" => "Very Good",
        "floor_description" => "Average thermal transmittance 0.17 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "roof_description" => "Average thermal transmittance 0.15 W/m²K",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "walls_description" => "Average thermal transmittance 0.28 W/m²K",
        "walls_energy_eff" => "Very Good",
        "walls_env_eff" => "Very Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
        "secondheat_description" => "Room heaters, mains gas",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Very Good",
        "mainheat_env_eff" => "Very Good",
        "mainheatcont_description" => "Time and temperature zone control",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 38% of fixed outlets",
        "lighting_energy_eff" => "Average",
        "lighting_env_eff" => "Average",
        "fixed_lighting_outlets_count" => nil,
        "floor_height" => "2.4",
        "main_heating_controls" => "Time and temperature zone control",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_150_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1150",
        "address1" => "17, Street Lodge",
        "address2" => nil,
        "address3" => nil,
        "address" => "17, Street Lodge",
        "postcode" => "BT7 1AA",
        "inspection_date" => "2012-02-09",
        "uprn" => 1245,
        "environment_impact_potential" => "61",
        "energy_consumption_current" => "238",
        "energy_consumption_potential" => "157",
        "environment_impact_current" => "44",
        "co2_emissions_current" => "8.8",
        "co2_emiss_curr_per_floor_area" => "57",
        "co2_emissions_potential" => "5.8",
        "total_floor_area" => "155",
        "lodgement_date" => "2022-10-05",
        "report_type" => "2",
        "posttown" => "Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "53",
        "current_energy_rating" => "E",
        "potential_energy_efficiency" => "69",
        "potential_energy_rating" => "C",
        "extension_count" => "0",
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => "5",
        "number_habitable_rooms" => "5",
        "low_energy_lighting" => "0",
        "low_energy_fixed_lighting_outlets_count" => "0",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "Bungalow",
        "transaction_type" => nil,
        "construction_age_band" => "England and Wales: 1991-1995",
        "built_form" => "Detached",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing installed before 2002",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "141",
        "lighting_cost_potential" => "70",
        "heating_cost_current" => "1202",
        "heating_cost_potential" => "844",
        "hot_water_cost_current" => "271",
        "hot_water_cost_potential" => "151",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system, no cylinder thermostat",
        "hot_water_energy_eff" => "Poor",
        "hot_water_env_eff" => "Very Poor",
        "floor_description" => "Solid, limited insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Roof room(s), insulated",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Cavity wall, as built, insulated (assumed)",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Average",
        "windows_env_eff" => "Average",
        "secondheat_description" => "Room heaters, electric",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => "Average",
        "mainheat_env_eff" => "Average",
        "mainheatcont_description" => "Programmer, no room thermostat",
        "mainheatc_energy_eff" => "Very Poor",
        "mainheatc_env_eff" => "Very Poor",
        "lighting_description" => "No low energy lighting",
        "lighting_energy_eff" => "Very Poor",
        "lighting_env_eff" => "Very Poor",
        "fixed_lighting_outlets_count" => "14",
        "floor_height" => "2.5",
        "main_heating_controls" => "Programmer, no room thermostat",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_160_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0160",
        "address1" => "1 The Lodge",
        "address2" => "20 Some Road",
        "address3" => nil,
        "address" => "1 The Lodge, 20 Some Road",
        "postcode" => "BT8 6AA",
        "inspection_date" => "2012-03-14",
        "uprn" => 1245,
        "environment_impact_potential" => "79",
        "energy_consumption_current" => "85",
        "energy_consumption_potential" => "80",
        "environment_impact_current" => "78",
        "co2_emissions_current" => "10",
        "co2_emiss_curr_per_floor_area" => "17",
        "co2_emissions_potential" => "9.9",
        "total_floor_area" => "590",
        "lodgement_date" => "2022-11-05",
        "report_type" => "3",
        "posttown" => "Post Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "80",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "82",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "48",
        "low_energy_fixed_lighting_outlets_count" => "25",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => nil,
        "construction_age_band" => "2009",
        "built_form" => "Semi-Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Oil: heating oil",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 3,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "568",
        "lighting_cost_potential" => "383",
        "heating_cost_current" => "1177",
        "heating_cost_potential" => "1216",
        "hot_water_cost_current" => "304",
        "hot_water_cost_potential" => "304",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Average thermal transmittance 0.25 W/m²K",
        "floor_energy_eff" => "Good",
        "floor_env_eff" => "Good",
        "roof_description" => "Average thermal transmittance 0.18 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Average thermal transmittance 0.31 W/m²K",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Good",
        "windows_env_eff" => "Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Time and temperature zone control",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 52% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "52",
        "floor_height" => "2.5",
        "main_heating_controls" => "Time and temperature zone control",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_160_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1160",
        "address1" => "1, Some Street",
        "address2" => nil,
        "address3" => nil,
        "address" => "1, Some Street",
        "postcode" => "BT8 6AA",
        "inspection_date" => "2012-06-15",
        "uprn" => 1245,
        "environment_impact_potential" => "41",
        "energy_consumption_current" => "524",
        "energy_consumption_potential" => "289",
        "environment_impact_current" => "16",
        "co2_emissions_current" => "11",
        "co2_emiss_curr_per_floor_area" => "128",
        "co2_emissions_potential" => "6.3",
        "total_floor_area" => "90",
        "lodgement_date" => "2022-11-05",
        "report_type" => "2",
        "posttown" => "Posttown",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "22",
        "current_energy_rating" => "F",
        "potential_energy_efficiency" => "53",
        "potential_energy_rating" => "E",
        "extension_count" => "4",
        "number_open_fireplaces" => "1",
        "number_heated_rooms" => "4",
        "number_habitable_rooms" => "4",
        "low_energy_lighting" => "0",
        "low_energy_fixed_lighting_outlets_count" => "0",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "Bungalow",
        "transaction_type" => nil,
        "construction_age_band" => "England and Wales: before 1900",
        "built_form" => "Detached",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing, unknown install date",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "96",
        "lighting_cost_potential" => "48",
        "heating_cost_current" => "1606",
        "heating_cost_potential" => "919",
        "hot_water_cost_current" => "313",
        "hot_water_cost_potential" => "139",
        "multi_glaze_proportion" => "35",
        "hotwater_description" => "From main system, no cylinder thermostat",
        "hot_water_energy_eff" => "Poor",
        "hot_water_env_eff" => "Very Poor",
        "floor_description" => "Solid, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Pitched, no insulation",
        "roof_energy_eff" => "Very Poor",
        "roof_env_eff" => "Very Poor",
        "walls_description" => "Granite or whinstone, as built, no insulation (assumed)",
        "walls_energy_eff" => "Very Poor",
        "walls_env_eff" => "Very Poor",
        "windows_description" => "Partial double glazing",
        "windows_energy_eff" => "Poor",
        "windows_env_eff" => "Poor",
        "secondheat_description" => "Room heaters, dual fuel (mineral and wood)",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => "Average",
        "mainheat_env_eff" => "Average",
        "mainheatcont_description" => "Programmer, TRVs and bypass",
        "mainheatc_energy_eff" => "Average",
        "mainheatc_env_eff" => "Average",
        "lighting_description" => "No low energy lighting",
        "lighting_energy_eff" => "Very Poor",
        "lighting_env_eff" => "Very Poor",
        "fixed_lighting_outlets_count" => "10",
        "floor_height" => "2.35",
        "main_heating_controls" => "Programmer, TRVs and bypass",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_161_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0161",
        "address1" => "16 Street Lane",
        "address2" => nil,
        "address3" => nil,
        "address" => "16 Street Lane",
        "postcode" => "BT9 5AA",
        "inspection_date" => "2012-09-16",
        "uprn" => 1245,
        "environment_impact_potential" => "77",
        "energy_consumption_current" => "119",
        "energy_consumption_potential" => "115",
        "environment_impact_current" => "76",
        "co2_emissions_current" => "2.8",
        "co2_emiss_curr_per_floor_area" => "25",
        "co2_emissions_potential" => "2.7",
        "total_floor_area" => "111",
        "lodgement_date" => "2022-12-05",
        "report_type" => "3",
        "posttown" => "BELFAST",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "82",
        "current_energy_rating" => "B",
        "potential_energy_efficiency" => "83",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "62",
        "low_energy_fixed_lighting_outlets_count" => nil,
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => nil,
        "construction_age_band" => "2012",
        "built_form" => "Semi-Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Oil: heating oil",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "89",
        "lighting_cost_potential" => "64",
        "heating_cost_current" => "293",
        "heating_cost_potential" => "298",
        "hot_water_cost_current" => "184",
        "hot_water_cost_potential" => "184",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Average thermal transmittance 0.19 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "roof_description" => "Average thermal transmittance 0.16 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Average thermal transmittance 0.29 W/m²K",
        "walls_energy_eff" => "Very Good",
        "walls_env_eff" => "Very Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Time and temperature zone control",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 62% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => nil,
        "floor_height" => "2.55",
        "main_heating_controls" => "Time and temperature zone control",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_161_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1161",
        "address1" => "22 Lane Street",
        "address2" => nil,
        "address3" => nil,
        "address" => "22 Lane Street",
        "postcode" => "BT9 5AA",
        "inspection_date" => "2012-09-02",
        "uprn" => 1245,
        "environment_impact_potential" => "55",
        "energy_consumption_current" => "278",
        "energy_consumption_potential" => "202",
        "environment_impact_current" => "43",
        "co2_emissions_current" => "5.8",
        "co2_emiss_curr_per_floor_area" => "70",
        "co2_emissions_potential" => "4.2",
        "total_floor_area" => "82",
        "lodgement_date" => "2022-12-05",
        "report_type" => "2",
        "posttown" => "Posttown",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "56",
        "current_energy_rating" => "D",
        "potential_energy_efficiency" => "69",
        "potential_energy_rating" => "C",
        "extension_count" => "1",
        "number_open_fireplaces" => "1",
        "number_heated_rooms" => "4",
        "number_habitable_rooms" => "4",
        "low_energy_lighting" => "0",
        "low_energy_fixed_lighting_outlets_count" => "0",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => "natural",
        "tenure" => nil,
        "property_type" => "House",
        "transaction_type" => nil,
        "construction_age_band" => "England and Wales: before 1900",
        "built_form" => "Mid-Terrace",
        "energy_tariff" => "Single",
        "glazed_type" => "double glazing installed before 2002",
        "glazed_area" => "Normal",
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "91",
        "lighting_cost_potential" => "46",
        "heating_cost_current" => "676",
        "heating_cost_potential" => "557",
        "hot_water_cost_current" => "268",
        "hot_water_cost_potential" => "143",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system, no cylinder thermostat",
        "hot_water_energy_eff" => "Poor",
        "hot_water_env_eff" => "Poor",
        "floor_description" => "Solid, no insulation (assumed)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Pitched, 150 mm loft insulation",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Solid brick, as built, no insulation (assumed)",
        "walls_energy_eff" => "Very Poor",
        "walls_env_eff" => "Very Poor",
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => "Average",
        "windows_env_eff" => "Average",
        "secondheat_description" => "Room heaters, coal",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => "Average",
        "mainheat_env_eff" => "Average",
        "mainheatcont_description" => "Programmer, TRVs and bypass",
        "mainheatc_energy_eff" => "Average",
        "mainheatc_env_eff" => "Average",
        "lighting_description" => "No low energy lighting",
        "lighting_energy_eff" => "Very Poor",
        "lighting_env_eff" => "Very Poor",
        "fixed_lighting_outlets_count" => "14",
        "floor_height" => "2.45",
        "main_heating_controls" => "Programmer, TRVs and bypass",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_170_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0170",
        "address1" => "999 Letsbe Avenue",
        "address2" => "District",
        "address3" => nil,
        "address" => "999 Letsbe Avenue, District",
        "postcode" => "BT10 0AA",
        "inspection_date" => "2011-12-09",
        "uprn" => 1245,
        "environment_impact_potential" => "81",
        "energy_consumption_current" => "109",
        "energy_consumption_potential" => "104",
        "environment_impact_current" => "80",
        "co2_emissions_current" => "2.2",
        "co2_emiss_curr_per_floor_area" => "21",
        "co2_emissions_potential" => "2.2",
        "total_floor_area" => "108",
        "lodgement_date" => "2023-01-05",
        "report_type" => "3",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "79",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "80",
        "potential_energy_rating" => "C",
        "extension_count" => nil,
        "number_open_fireplaces" => "1",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "50",
        "low_energy_fixed_lighting_outlets_count" => "5",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2012",
        "built_form" => "Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Gas: mains gas",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "86",
        "lighting_cost_potential" => "57",
        "heating_cost_current" => "350",
        "heating_cost_potential" => "354",
        "hot_water_cost_current" => "104",
        "hot_water_cost_potential" => "104",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Average thermal transmittance 0.17 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "roof_description" => "Average thermal transmittance 0.22 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Average thermal transmittance 0.30 W/m²K",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 50% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "10",
        "floor_height" => "2.6",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => "N09000003",
        "local_authority_label" => "Belfast",
        "constituency_label" => nil,
        "constituency" => "N09000003",
        "country" => "Northern Ireland",
        "region" => "N99999999",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_170_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1170",
        "address1" => "1 High Street",
        "address2" => nil,
        "address3" => nil,
        "address" => "1 High Street",
        "postcode" => "BT10 0AA",
        "inspection_date" => "2011-09-26",
        "uprn" => 1245,
        "environment_impact_potential" => "37",
        "energy_consumption_current" => "405",
        "energy_consumption_potential" => "273",
        "environment_impact_current" => "21",
        "co2_emissions_current" => "14",
        "co2_emiss_curr_per_floor_area" => "102",
        "co2_emissions_potential" => "9.4",
        "total_floor_area" => "136",
        "lodgement_date" => "2023-01-05",
        "report_type" => "2",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "27",
        "current_energy_rating" => "F",
        "potential_energy_efficiency" => "48",
        "potential_energy_rating" => "E",
        "extension_count" => "0",
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => "6",
        "number_habitable_rooms" => "6",
        "low_energy_lighting" => "8",
        "low_energy_fixed_lighting_outlets_count" => "1",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => nil,
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "122",
        "lighting_cost_potential" => "64",
        "heating_cost_current" => "2079",
        "heating_cost_potential" => "1490",
        "hot_water_cost_current" => "387",
        "hot_water_cost_potential" => "194",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system, no cylinder thermostat",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Solid, no insulation (assumed)",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "Pitched, no insulation (assumed)",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Solid brick, as built, no insulation (assumed)",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "None",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Programmer, no room thermostat",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "Low energy lighting in 8% of fixed outlets",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "12",
        "floor_height" => "2.12",
        "main_heating_controls" => "Programmer, no room thermostat",
        "local_authority" => "N09000003",
        "local_authority_label" => "Belfast",
        "constituency_label" => nil,
        "constituency" => "N09000003",
        "country" => "Northern Ireland",
        "region" => "N99999999",
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_171_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0171",
        "address1" => "5",
        "address2" => "Street Lane",
        "address3" => "District",
        "address" => "5, Street Lane, District",
        "postcode" => "BT11 9AA",
        "inspection_date" => "2013-07-11",
        "uprn" => 1245,
        "environment_impact_potential" => "81",
        "energy_consumption_current" => "133",
        "energy_consumption_potential" => "127",
        "environment_impact_current" => "80",
        "co2_emissions_current" => "1.6",
        "co2_emiss_curr_per_floor_area" => "25",
        "co2_emissions_potential" => "1.5",
        "total_floor_area" => "64",
        "lodgement_date" => "2023-02-05",
        "report_type" => "3",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "77",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "78",
        "potential_energy_rating" => "C",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "50",
        "low_energy_fixed_lighting_outlets_count" => "6",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2013",
        "built_form" => "Detached",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Gas: mains gas",
        "unheated_corridor_length" => nil,
        "floor_level" => "3",
        "flat_top_storey" => "Y",
        "flat_storey_count" => 1,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "68",
        "lighting_cost_potential" => "45",
        "heating_cost_current" => "295",
        "heating_cost_potential" => "299",
        "hot_water_cost_current" => "80",
        "hot_water_cost_potential" => "80",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "(other premises below)",
        "floor_energy_eff" => "N/A",
        "floor_env_eff" => "N/A",
        "roof_description" => "Average thermal transmittance 0.16 W/m²K",
        "roof_energy_eff" => "Good",
        "roof_env_eff" => "Good",
        "walls_description" => "Average thermal transmittance 0.27 W/m²K",
        "walls_energy_eff" => "Very Good",
        "walls_env_eff" => "Very Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
        "secondheat_description" => "Room heaters, electric",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 50% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "12",
        "floor_height" => "3",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_171_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1171",
        "address1" => "12 Lane Street",
        "address2" => nil,
        "address3" => nil,
        "address" => "12 Lane Street",
        "postcode" => "BT11 9AA",
        "inspection_date" => "2013-04-13",
        "uprn" => 1245,
        "environment_impact_potential" => "65",
        "energy_consumption_current" => "297",
        "energy_consumption_potential" => "184",
        "environment_impact_current" => "45",
        "co2_emissions_current" => "4.7",
        "co2_emiss_curr_per_floor_area" => "72",
        "co2_emissions_potential" => "2.9",
        "total_floor_area" => "65",
        "lodgement_date" => "2023-02-05",
        "report_type" => "2",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "56",
        "current_energy_rating" => "D",
        "potential_energy_efficiency" => "73",
        "potential_energy_rating" => "C",
        "extension_count" => "0",
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => "5",
        "number_habitable_rooms" => "5",
        "low_energy_lighting" => "0",
        "low_energy_fixed_lighting_outlets_count" => "0",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => nil,
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "75",
        "lighting_cost_potential" => "38",
        "heating_cost_current" => "545",
        "heating_cost_potential" => "369",
        "hot_water_cost_current" => "271",
        "hot_water_cost_potential" => "141",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system, no cylinder thermostat",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Solid, no insulation (assumed)",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "Pitched, 300+ mm loft insulation",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Cavity wall, as built, insulated (assumed)",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "Room heaters, dual fuel (mineral and wood)",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Programmer, TRVs and bypass",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "No low energy lighting",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "9",
        "floor_height" => "2.4",
        "main_heating_controls" => "Programmer, TRVs and bypass",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_172_sap_data) do
      { "certificate_number" => "1000-0000-0000-0000-0172",
        "address1" => "32 Street Lane",
        "address2" => "District",
        "address3" => nil,
        "address" => "32 Street Lane, District",
        "postcode" => "BT12 4AA",
        "inspection_date" => "2014-03-25",
        "uprn" => 1245,
        "environment_impact_potential" => "84",
        "energy_consumption_current" => "102",
        "energy_consumption_potential" => "96",
        "environment_impact_current" => "83",
        "co2_emissions_current" => "1.7",
        "co2_emiss_curr_per_floor_area" => "19",
        "co2_emissions_potential" => "1.6",
        "total_floor_area" => "87",
        "lodgement_date" => "2023-03-05",
        "report_type" => "3",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "80",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "81",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "50",
        "low_energy_fixed_lighting_outlets_count" => "5",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2012",
        "built_form" => "Mid-Terrace",
        "energy_tariff" => "standard tariff",
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => "Gas: mains gas",
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "83",
        "lighting_cost_potential" => "55",
        "heating_cost_current" => "277",
        "heating_cost_potential" => "281",
        "hot_water_cost_current" => "114",
        "hot_water_cost_potential" => "114",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => "Good",
        "hot_water_env_eff" => "Good",
        "floor_description" => "Average thermal transmittance 0.17 W/m²K",
        "floor_energy_eff" => "Very Good",
        "floor_env_eff" => "Very Good",
        "roof_description" => "Average thermal transmittance 0.14 W/m²K",
        "roof_energy_eff" => "Very Good",
        "roof_env_eff" => "Very Good",
        "walls_description" => "Average thermal transmittance 0.30 W/m²K",
        "walls_energy_eff" => "Good",
        "walls_env_eff" => "Good",
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => "Very Good",
        "windows_env_eff" => "Very Good",
        "secondheat_description" => "None",
        "sheating_energy_eff" => "N/A",
        "sheating_env_eff" => "N/A",
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => "Good",
        "mainheat_env_eff" => "Good",
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => "Good",
        "mainheatc_env_eff" => "Good",
        "lighting_description" => "Low energy lighting in 50% of fixed outlets",
        "lighting_energy_eff" => "Good",
        "lighting_env_eff" => "Good",
        "fixed_lighting_outlets_count" => "10",
        "floor_height" => "2.45",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_172_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1172",
        "address1" => "30 Street Road",
        "address2" => "Smalltown",
        "address3" => nil,
        "address" => "30 Street Road, Smalltown",
        "postcode" => "BT12 4AA",
        "inspection_date" => "2013-08-19",
        "uprn" => 1245,
        "environment_impact_potential" => "64",
        "energy_consumption_current" => "212",
        "energy_consumption_potential" => "128",
        "environment_impact_current" => "43",
        "co2_emissions_current" => "12",
        "co2_emiss_curr_per_floor_area" => "53",
        "co2_emissions_potential" => "7.5",
        "total_floor_area" => "234",
        "lodgement_date" => "2023-03-05",
        "report_type" => "2",
        "posttown" => "POSTTOWN",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "55",
        "current_energy_rating" => "D",
        "potential_energy_efficiency" => "73",
        "potential_energy_rating" => "C",
        "extension_count" => "0",
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => "8",
        "number_habitable_rooms" => "8",
        "low_energy_lighting" => "23",
        "low_energy_fixed_lighting_outlets_count" => "6",
        "solar_water_heating_flag" => "N",
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => nil,
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => "N",
        "photo_supply" => "0",
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "173",
        "lighting_cost_potential" => "98",
        "heating_cost_current" => "2258",
        "heating_cost_potential" => "1362",
        "hot_water_cost_current" => "314",
        "hot_water_cost_potential" => "197",
        "multi_glaze_proportion" => "100",
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Solid, limited insulation (assumed)",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "Pitched, 300+ mm loft insulation",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Cavity wall, as built, insulated (assumed)",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "Fully double glazed",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "None",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "Low energy lighting in 23% of fixed outlets",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "26",
        "floor_height" => "2.57",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_173_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1173",
        "address1" => "1b Address Lane",
        "address2" => "Localtion Place",
        "address3" => nil,
        "address" => "1b Address Lane, Localtion Place",
        "postcode" => "BT13 3AA",
        "inspection_date" => "2015-01-29",
        "uprn" => 1245,
        "environment_impact_potential" => "81",
        "energy_consumption_current" => "96",
        "energy_consumption_potential" => "96",
        "environment_impact_current" => "81",
        "co2_emissions_current" => "2.2",
        "co2_emiss_curr_per_floor_area" => "21",
        "co2_emissions_potential" => "2.2",
        "total_floor_area" => "107",
        "lodgement_date" => "2023-04-05",
        "report_type" => "3",
        "posttown" => "Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "83",
        "current_energy_rating" => "B",
        "potential_energy_efficiency" => "83",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "1",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "100",
        "low_energy_fixed_lighting_outlets_count" => "20",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2014",
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "70",
        "lighting_cost_potential" => "70",
        "heating_cost_current" => "311",
        "heating_cost_potential" => "311",
        "hot_water_cost_current" => "158",
        "hot_water_cost_potential" => "158",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Average thermal transmittance 0.13 W/m²K",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "Average thermal transmittance 0.11 W/m²K",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Average thermal transmittance 0.21 W/m²K",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "Room heaters, wood logs",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, oil",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Time and temperature zone control",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "Low energy lighting in all fixed outlets",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "20",
        "floor_height" => "2.55",
        "main_heating_controls" => "Time and temperature zone control",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_174_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1174",
        "address1" => "12,Addess Lane",
        "address2" => nil,
        "address3" => nil,
        "address" => "12,Addess Lane",
        "postcode" => "BT14 7AA",
        "inspection_date" => "2017-05-12",
        "uprn" => 1245,
        "environment_impact_potential" => "84",
        "energy_consumption_current" => "98",
        "energy_consumption_potential" => "94",
        "environment_impact_current" => "83",
        "co2_emissions_current" => "1.8",
        "co2_emiss_curr_per_floor_area" => "19",
        "co2_emissions_potential" => "1.7",
        "total_floor_area" => "97",
        "lodgement_date" => "2023-05-05",
        "report_type" => "3",
        "posttown" => "Town",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "81",
        "current_energy_rating" => "B",
        "potential_energy_efficiency" => "82",
        "potential_energy_rating" => "B",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "57",
        "low_energy_fixed_lighting_outlets_count" => "12",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2014",
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => nil,
        "flat_top_storey" => "N",
        "flat_storey_count" => 2,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "97",
        "lighting_cost_potential" => "68",
        "heating_cost_current" => "303",
        "heating_cost_potential" => "307",
        "hot_water_cost_current" => "110",
        "hot_water_cost_potential" => "110",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Average thermal transmittance 0.21 W/m²K",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "Average thermal transmittance 0.17 W/m²K",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Average thermal transmittance 0.20 W/m²K",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "None",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Programmer, room thermostat and TRVs",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "Low energy lighting in 57% of fixed outlets",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "21",
        "floor_height" => "2.55",
        "main_heating_controls" => "Programmer, room thermostat and TRVs",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    let(:expected_ni_180_rdsap_data) do
      { "certificate_number" => "1000-0000-0000-0000-1180",
        "address1" => "999 Letsbe Avenue",
        "address2" => "Anydistrict",
        "address3" => nil,
        "address" => "999 Letsbe Avenue, Anydistrict",
        "postcode" => "BT15 2AA",
        "inspection_date" => "2020-09-12",
        "uprn" => 1245,
        "environment_impact_potential" => "82",
        "energy_consumption_current" => "104",
        "energy_consumption_potential" => "104",
        "environment_impact_current" => "82",
        "co2_emissions_current" => "1.8",
        "co2_emiss_curr_per_floor_area" => "20",
        "co2_emissions_potential" => "1.8",
        "total_floor_area" => "90",
        "lodgement_date" => "2023-06-05",
        "report_type" => "3",
        "posttown" => "BELFAST",
        "lodgement_datetime" => "2021-07-21 11:26:28",
        "current_energy_efficiency" => "80",
        "current_energy_rating" => "C",
        "potential_energy_efficiency" => "80",
        "potential_energy_rating" => "C",
        "extension_count" => nil,
        "number_open_fireplaces" => "0",
        "number_heated_rooms" => nil,
        "number_habitable_rooms" => nil,
        "low_energy_lighting" => "100",
        "low_energy_fixed_lighting_outlets_count" => "15",
        "solar_water_heating_flag" => nil,
        "mechanical_ventilation" => nil,
        "tenure" => nil,
        "property_type" => nil,
        "transaction_type" => nil,
        "construction_age_band" => "2020",
        "built_form" => nil,
        "energy_tariff" => nil,
        "glazed_type" => nil,
        "glazed_area" => nil,
        "heat_loss_corridor" => nil,
        "main_fuel" => nil,
        "unheated_corridor_length" => nil,
        "floor_level" => "2",
        "flat_top_storey" => "N",
        "flat_storey_count" => 1,
        "mains_gas_flag" => nil,
        "photo_supply" => nil,
        "wind_turbine_count" => 0,
        "lighting_cost_current" => "71",
        "lighting_cost_potential" => "71",
        "heating_cost_current" => "354",
        "heating_cost_potential" => "354",
        "hot_water_cost_current" => "79",
        "hot_water_cost_potential" => "79",
        "multi_glaze_proportion" => nil,
        "hotwater_description" => "From main system",
        "hot_water_energy_eff" => nil,
        "hot_water_env_eff" => nil,
        "floor_description" => "Average thermal transmittance 0.13 W/m²K",
        "floor_energy_eff" => nil,
        "floor_env_eff" => nil,
        "roof_description" => "(other premises above)",
        "roof_energy_eff" => nil,
        "roof_env_eff" => nil,
        "walls_description" => "Average thermal transmittance 0.21 W/m²K",
        "walls_energy_eff" => nil,
        "walls_env_eff" => nil,
        "windows_description" => "High performance glazing",
        "windows_energy_eff" => nil,
        "windows_env_eff" => nil,
        "secondheat_description" => "None",
        "sheating_energy_eff" => nil,
        "sheating_env_eff" => nil,
        "mainheat_description" => "Boiler and radiators, mains gas",
        "mainheat_energy_eff" => nil,
        "mainheat_env_eff" => nil,
        "mainheatcont_description" => "Time and temperature zone control by suitable arrangement of plumbing and electrical services",
        "mainheatc_energy_eff" => nil,
        "mainheatc_env_eff" => nil,
        "lighting_description" => "Low energy lighting in all fixed outlets",
        "lighting_energy_eff" => nil,
        "lighting_env_eff" => nil,
        "fixed_lighting_outlets_count" => "15",
        "floor_height" => "2.5",
        "main_heating_controls" => "Time and temperature zone control by suitable arrangement of plumbing and electrical services",
        "local_authority" => nil,
        "local_authority_label" => nil,
        "constituency_label" => nil,
        "constituency" => nil,
        "country" => "Northern Ireland",
        "region" => nil,
        "uprn_source" => "Energy Assessor" }
    end

    it "returns a row with the required data for SAP-NI 12.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0120" }
      expect(result).to eq expected_ni_120_sap_data
    end

    it "returns a row with the required data for SAP-NI 12.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1120" }
      expect(result).to eq expected_ni_120_rdsap_data
    end

    it "returns a row with the required data for SAP-NI 13.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0130" }
      expect(result).to eq expected_ni_130_sap_data
    end

    it "returns a row with the required data for SAP-NI 13.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1130" }
      expect(result).to eq expected_ni_130_rdsap_data
    end

    it "returns a row with the required data for SAP-NI 14.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0140" }
      expect(result).to eq expected_ni_140_sap_data
    end

    it "returns a row with the required data for SAP-NI 14.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1140" }
      expect(result).to eq expected_ni_140_rdsap_data
    end

    it "returns a row with the required data for SAP-NI 14.1 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0141" }
      expect(result).to eq expected_ni_141_sap_data
    end

    it "returns a row with the required data for SAP-NI 14.1 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1141" }
      expect(result).to eq expected_ni_141_rdsap_data
    end

    it "returns a row with the required data for SAP-NI 14.2 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0142" }
      expect(result).to eq expected_ni_142_sap_data
    end

    it "returns a row with the required data for SAP-NI 14.2 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1142" }
      expect(result).to eq expected_ni_142_rdsap_data
    end

    # SAP-Schema-NI-15.0 tests
    it "returns a row with the required data for SAP-NI 15.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0150" }
      expect(result).to eq expected_ni_150_sap_data
    end

    it "returns a row with the required data for SAP-NI 15.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1150" }
      expect(result).to eq expected_ni_150_rdsap_data
    end

    # SAP-Schema-NI-16.0 tests
    it "returns a row with the required data for SAP-NI 16.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0160" }
      expect(result).to eq expected_ni_160_sap_data
    end

    it "returns a row with the required data for SAP-NI 16.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1160" }
      expect(result).to eq expected_ni_160_rdsap_data
    end

    # SAP-Schema-NI-16.1 tests
    it "returns a row with the required data for SAP-NI 16.1 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0161" }
      expect(result).to eq expected_ni_161_sap_data
    end

    it "returns a row with the required data for SAP-NI 16.1 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1161" }
      expect(result).to eq expected_ni_161_rdsap_data
    end

    # SAP-Schema-NI-17.0 tests
    it "returns a row with the required data for SAP-NI 17.0 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0170" }
      expect(result).to eq expected_ni_170_sap_data
    end

    it "returns a row with the required data for SAP-NI 17.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1170" }
      expect(result).to eq expected_ni_170_rdsap_data
    end

    # SAP-Schema-NI-17.1 tests
    it "returns a row with the required data for SAP-NI 17.1 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0171" }
      expect(result).to eq expected_ni_171_sap_data
    end

    it "returns a row with the required data for SAP-NI 17.1 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1171" }
      expect(result).to eq expected_ni_171_rdsap_data
    end

    # SAP-Schema-NI-17.2 tests
    it "returns a row with the required data for SAP-NI 17.2 and of assessment_type sap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0172" }
      expect(result).to eq expected_ni_172_sap_data
    end

    it "returns a row with the required data for SAP-NI 17.2 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1172" }
      expect(result).to eq expected_ni_172_rdsap_data
    end

    # RdSAP-Schema-NI-17.3 test (RdSAP only)
    it "returns a row with the required data for RdSAP-NI 17.3 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1173" }
      expect(result).to eq expected_ni_173_rdsap_data
    end

    # RdSAP-Schema-NI-17.4 test (RdSAP only)
    it "returns a row with the required data for RdSAP-NI 17.4 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1174" }
      expect(result).to eq expected_ni_174_rdsap_data
    end

    # RdSAP-Schema-NI-18.0.0 test (RdSAP only)
    it "returns a row with the required data for RdSAP-NI 18.0.0 and of assessment_type rdsap" do
      result = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1180" }
      expect(result).to eq expected_ni_180_rdsap_data
    end
  end

  context "when an assessment is from England or Wales" do
    it "does not include the assessment in the results" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0001" }).to be_nil
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0002" }).to be_nil
    end
  end

  context "when checking NI-specific construction age bands" do
    it "returns NI-specific construction age bands for RdSAP assessments" do
      ni_14_rdsap = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-1140" }
      expect(ni_14_rdsap["construction_age_band"]).to eq "England and Wales: before 1900"
    end

    it "returns year-based construction age bands for SAP assessments" do
      ni_14_sap = query_result.find { |i| i["certificate_number"] == "1000-0000-0000-0000-0140" }
      expect(ni_14_sap["construction_age_band"]).to eq "1750"
    end
  end

  context "when checking country field" do
    it "returns 'Northern Ireland' for all NI assessments" do
      query_result.each do |result|
        expect(result["country"]).to eq "Northern Ireland"
      end
    end
  end
end
