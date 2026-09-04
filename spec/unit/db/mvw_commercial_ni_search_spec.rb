require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

describe "Commercial Materialized View" do
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"
  include_context "when saving enum data to lookup tables"

  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_commercial_ni_search")
  end

  let(:cepc_80_expected_data) do
    { "certificate_number" => "0000-3000-0000-0000-0800",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "postcode" => "BT10 0AA",
      "uprn" => nil,
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "property_type" => "B1 Offices and Workshop businesses",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "constituency" => "N06000003",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "lodgement_date" => "2020-05-04",
      "new_build_benchmark" => "28",
      "existing_stock_benchmark" => "81",
      "building_level" => "3",
      "main_heating_fuel" => "Natural Gas",
      "other_fuel_desc" => "Test",
      "special_energy_uses" => "Test sp",
      "renewable_sources" => "Renewable sources test",
      "floor_area" => "403",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "typical_emissions" => "67.98",
      "building_emissions" => "67.09",
      "aircon_present" => "No",
      "aircon_kw_rating" => "100",
      "estimated_aircon_kw_rating" => "3",
      "ac_inspection_commissioned" => "1",
      "building_environment" => "Air Conditioning",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "local_authority_label" => "Belfast",
      "constituency_label" => "Belfast South",
      "posttown" => "Belfast",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "primary_energy_value" => "413.22",
      "report_type" => "3",
      "uprn_source" => nil }
  end

  let(:cepc_71_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => "67.09",
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0071",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => "413.22",
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "typical_emissions" => "67.98",
      "uprn" => 71,
      "uprn_source" => "Energy Assessor",
    }
  end
  let(:cepc_70_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => "67.09",
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0070",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "typical_emissions" => "67.98",
      "uprn" => 70,
      "uprn_source" => "Energy Assessor",
    }
  end

  let(:cepc_60_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => "67.09",
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0060",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "typical_emissions" => "67.98",
      "uprn" => 60,
      "uprn_source" => "Energy Assessor",
    }
  end

  let(:cepc_51_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => "67.09",
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0051",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "typical_emissions" => "67.98",
      "uprn" => 51,
      "uprn_source" => "Energy Assessor",

    }
  end

  let(:cepc_50_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => "67.09",
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0050",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "42.07",
      "target_emissions" => "23.2",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "typical_emissions" => "67.98",
      "uprn" => 50,
      "uprn_source" => "Energy Assessor",
    }
  end

  let(:cepc_40_expected_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => nil,
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0040",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => "3",
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => nil,
      "target_emissions" => nil,
      "transaction_type" => nil,
      "typical_emissions" => nil,
      "uprn" => 40,
      "uprn_source" => "Energy Assessor",
    }
  end

  let(:cepc_31_expected_data) do
    {
      "ac_inspection_commissioned" => nil,
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => nil,
      "aircon_present" => nil,
      "asset_rating" => "80",
      "asset_rating_band" => "D",
      "building_emissions" => nil,
      "building_environment" => "Air Conditioning",
      "building_level" => "3",
      "certificate_number" => "0000-3000-0000-0000-0031",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "estimated_aircon_kw_rating" => nil,
      "existing_stock_benchmark" => "81",
      "floor_area" => "403",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28",
      "main_heating_fuel" => "Natural Gas",
      "new_build_benchmark" => "28",
      "other_fuel_desc" => "Test",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "primary_energy_value" => nil,
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => "Renewable sources test",
      "report_type" => "3",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => nil,
      "target_emissions" => nil,
      "transaction_type" => nil,
      "typical_emissions" => nil,
      "uprn" => 31,
      "uprn_source" => "Energy Assessor",
    }
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries

    type_of_assessment = "CEPC"

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0800", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0007"
    })
    add_assessment_eav(assessment_id: "0000-3000-0000-0000-1800", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "country_id" => 3, "assessment_address_id" => "UPRN-000000000800"
    })

    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0031", schema_type: "CEPC-3.1", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0031-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000031"
    })
    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0040", schema_type: "CEPC-4.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0040-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000040"
    })

    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0050", schema_type: "CEPC-5.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0050-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000050"
    })

    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0051", schema_type: "CEPC-5.1", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0051-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000051"
    })
    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0060", schema_type: "CEPC-6.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0060-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000060"
    })

    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0070", schema_type: "CEPC-7.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0070-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000070"
    })

    add_assessment_eav(assessment_id: "0000-3000-0000-0000-0071", schema_type: "CEPC-7.1", type_of_assessment: "CEPC", type: "cepc", different_fields: {
      "postcode" => "BT10 0AA", "related_rrn" => "0000-0071-0000-0000-0006", "country_id" => 3, "assessment_address_id" => "UPRN-000000000071"
    })

    add_assessment_eav(assessment_id: "0000-1000-0000-0000-2800", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
      "postcode" => "SW10 0AA", "country_id" => 1, "assessment_address_id" => "UPRN-000000000000", "registration_date" => "2021-03-19"
    })
    add_assessment_eav(assessment_id: "1000-3000-0000-0000-1800", schema_type: "SAP-Schema-NI-18.0.0", type_of_assessment: "SAP", different_fields: {
      "postcode" => "BT10 0AA", "country_id" => 3
    })

    import_look_ups(schema_versions: %w[CEPC-NI-8.0.0 CEPC-NI-7.1 CEPC-7.1 CEPC-7.0 CEPC-6.0 CEPC-5.1 CEPC-5.0 CEPC-4.0 CEPC-3.1])
    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_ni_search")
  end

  it "returns a dataset with 8 commercial EPCs" do
    expect(query_result.length).to eq 9
  end

  it "does not return any commercial EPCs for EAW" do
    expect(query_result.map { |i| i["certificate_number"] }).not_to include("0000-1000-0000-0000-2800")
  end

  it "returns a the expected data for a CEPC-NI-8.0.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0800" }
    expect(result).to eq cepc_80_expected_data
  end

  it "returns a the expected data for a CEPC-7.1" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0071" }
    expect(result).to eq cepc_71_expected_data
  end

  it "returns the expected data for a CEPC-7.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0070" }
    expect(result).to eq cepc_70_expected_data
  end

  it "returns the expected data for a CEPC-6.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0060" }
    expect(result).to eq cepc_60_expected_data
  end

  it "returns the expected data for a CEPC-5.1" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0051" }
    expect(result).to eq cepc_51_expected_data
  end

  it "returns the expected data for a CEPC-5.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0050" }
    expect(result).to eq cepc_50_expected_data
  end

  it "returns the expected data for a CEPC-4.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0040" }
    expect(result).to eq cepc_40_expected_data
  end

  it "returns the expected data for a CEPC-3.1" do
    result = query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-0031" }
    expect(result).to eq cepc_31_expected_data
  end

  context "when an assessment has a URPN value in the assessment_address_id attribute" do
    it "returns a value for the uprn_source" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-3000-0000-0000-1800" }["uprn_source"]).to eq "Energy Assessor"
    end
  end

  context "when checking the columns of the materialized view" do
    let(:expected_columns) do
      %w[certificate_number address1 address2 address3 postcode uprn asset_rating asset_rating_band property_type inspection_date local_authority constituency transaction_type lodgement_date new_build_benchmark existing_stock_benchmark building_level main_heating_fuel other_fuel_desc special_energy_uses renewable_sources floor_area standard_emissions target_emissions typical_emissions building_emissions aircon_present aircon_kw_rating estimated_aircon_kw_rating ac_inspection_commissioned building_environment address local_authority_label constituency_label posttown lodgement_datetime primary_energy_value report_type uprn_source]
    end

    it "returns the correct columns" do
      expect(mview_columns("mvw_commercial_search").sort.map(&:downcase)).to eq expected_columns.sort.map(&:downcase)
    end
  end

  context "when checking commercial_reports table" do
    let(:commercial_reports_result) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM commercial_reports ORDER BY assessment_id",
      )
    end

    it "inserts a new commercial report record" do
      expect(commercial_reports_result.length).to eq 9
      expect(commercial_reports_result.first["assessment_id"]).to eq "0000-3000-0000-0000-0031"
    end

    it "inserts a new commercial report record with the correct related_certificate_number" do
      expect(commercial_reports_result.first["related_rrn"]).to eq "0000-0031-0000-0000-0006"
    end
  end
end
