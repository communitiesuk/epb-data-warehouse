require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe "DEC NI Report" do
  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_dec_ni_search")
  end

  let(:expected_dec_7_data) do
    { "certificate_number" => "0000-0000-0000-0000-0001",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "ac_inspection_commissioned" => "4",
      "address1" => "Mr Blobby's Sports Academy",
      "address2" => "Mr Blobby's Academy",
      "address3" => "Blobby Custard Lane",
      "address" => "Mr Blobby's Sports Academy, Mr Blobby's Academy, Blobby Custard Lane",
      "aircon_kw_rating" => "",
      "aircon_present" => "Y",
      "annual_electrical_fuel_usage" => 61,
      "annual_thermal_fuel_usage" => 161,
      "building_category" => "S3; H6",
      "building_environment" => "Mixed-mode with Natural Ventilation",
      "country" => "Northern Ireland",
      "current_operational_rating" => "77",
      "electric_co2" => "163",
      "estimated_aircon_kw_rating" => "2",
      "heating_co2" => "153",
      "inspection_date" => "2016-04-11",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2016-04-25",
      "lodgement_datetime" => Time.parse("2021-07-21 11:26:28.045000000 +0000"),
      "main_benchmark" => "Schools And Seasonal Public Buildings",
      "main_heating_fuel" => "Natural Gas",
      "nominated_date" => "2016-02-23",
      "occupancy_level" => "Extended Occupancy",
      "operational_rating_band" => "D",
      "or_assessment_end_date" => "2016-01-01",
      "other_fuel" => nil,
      "postcode" => "BT10 0AA",
      "posttown" => "POSTTOWN",
      "property_type" => "Schools And Seasonal Public Buildings; Swimming Pool Centre",
      "renewable_sources" => nil,
      "renewables_co2" => "0",
      "renewables_electrical" => "0",
      "renewables_fuel_thermal" => "0",
      "report_type" => "1",
      "special_energy_uses" => nil,
      "total_floor_area" => 4901,
      "typical_electrical_fuel_usage" => "67",
      "typical_thermal_fuel_usage" => 244,
      "typical_thermal_use" => 244,
      "uprn" => nil,
      "yr1_electricity_co2" => "266",
      "yr1_heating_co2" => "176",
      "yr1_operational_rating" => "95",
      "yr1_renewables_co2" => "0",
      "yr2_electricity_co2" => "333",
      "yr2_heating_co2" => "238",
      "yr2_operational_rating" => "113",
      "yr2_renewables_co2" => "0",
      "uprn_source" => nil }
  end
  let(:expected_dec_7_1_data) do
    expected_dec_7_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0002",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "address1" => nil,
      "address2" => "Place Early Years Centre",
      "address3" => "Address Road",
      "address" => "Place Early Years Centre, Address Road",
      "aircon_present" => "N",
      "annual_electrical_fuel_usage" => 49,
      "annual_thermal_fuel_usage" => 118,
      "building_category" => "S3;",
      "building_environment" => "Heating and Natural Ventilation",
      "current_operational_rating" => "80",
      "electric_co2" => "33",
      "estimated_aircon_kw_rating" => nil,
      "heating_co2" => "28",
      "inspection_date" => "2015-12-09",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2015-12-14",
      "nominated_date" => "2015-12-30",
      "or_assessment_end_date" => "2015-09-30",
      "posttown" => "Town",
      "property_type" => "Schools And Seasonal Public Buildings",
      "total_floor_area" => 1219,
      "typical_electrical_fuel_usage" => "51",
      "typical_thermal_fuel_usage" => 176,
      "typical_thermal_use" => 176,
      "yr1_electricity_co2" => "30",
      "yr1_heating_co2" => "24",
      "yr1_operational_rating" => "75",
      "yr2_electricity_co2" => "31",
      "yr2_heating_co2" => "29",
      "yr2_operational_rating" => "75",
    )
  end

  let(:expected_dec_common_data) do
    {
      "ac_inspection_commissioned" => "1",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "aircon_kw_rating" => "1",
      "aircon_present" => "Y",
      "annual_electrical_fuel_usage" => 1,
      "annual_thermal_fuel_usage" => 1,
      "building_category" => "C1",
      "building_environment" => "Heating and Natural Ventilation",
      "certificate_number" => "0000-0000-0000-0000-0004",
      "constituency" => "N06000003",
      "constituency_label" => "Belfast South",
      "country" => "Northern Ireland",
      "current_operational_rating" => "1",
      "electric_co2" => "7",
      "estimated_aircon_kw_rating" => "1",
      "heating_co2" => "3",
      "inspection_date" => "2020-05-04",
      "local_authority" => "N09000003",
      "local_authority_label" => "Belfast",
      "lodgement_date" => "2020-05-04",
      "lodgement_datetime" => "2021-07-21 11:26:28.045000000 +0000",
      "main_benchmark" => nil,
      "main_heating_fuel" => "Natural Gas",
      "nominated_date" => "2020-01-01",
      "occupancy_level" => nil,
      "operational_rating_band" => "A",
      "or_assessment_end_date" => "2020-05-01",
      "other_fuel" => "other",
      "postcode" => "BT10 0AA",
      "posttown" => "Whitbury",
      "property_type" => "B1 Offices and Workshop businesses",
      "renewable_sources" => nil,
      "renewables_co2" => "0",
      "renewables_electrical" => "1",
      "renewables_fuel_thermal" => "1",
      "report_type" => "1",
      "special_energy_uses" => "special",
      "total_floor_area" => 99,
      "typical_electrical_fuel_usage" => "1",
      "typical_thermal_fuel_usage" => 1,
      "typical_thermal_use" => 1,
      "uprn" => nil,
      "uprn_source" => nil,
      "yr1_electricity_co2" => "10",
      "yr1_heating_co2" => "5",
      "yr1_operational_rating" => "24",
      "yr1_renewables_co2" => "1",
      "yr2_electricity_co2" => "15",
      "yr2_heating_co2" => "10",
      "yr2_operational_rating" => "40",
      "yr2_renewables_co2" => "2",
    }
  end

  let(:expected_dec_4_data) do
    expected_dec_common_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0004",
      "occupancy_level" => nil,
      "uprn" => "200000000004".to_i,
      "uprn_source" => "Energy Assessor",
    )
  end

  let(:expected_dec_5_data) do
    expected_dec_common_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0005",
      "occupancy_level" => nil,
    )
  end

  let(:expected_dec_5_1_data) do
    expected_dec_common_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0051",
      "occupancy_level" => nil,
    )
  end

  let(:expected_dec_6_data) do
    expected_dec_common_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0006",
      "occupancy_level" => "level",
      "uprn" => "200000000006".to_i,
      "uprn_source" => "Energy Assessor",
    )
  end

  let(:expected_dec_8_data) do
    expected_dec_common_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0003",
      "occupancy_level" => "level",
      "uprn" => "200000000008".to_i,
      "uprn_source" => "Energy Assessor",
    )
  end

  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries
    type_of_assessment = "DEC"

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-7.0", type_of_assessment:, type: "dec+rr", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-7.1", type_of_assessment:, type: "dec+rr", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0005"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "dec", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0006", "assessment_address_id" => "UPRN-200000000008"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", schema_type: "CEPC-4.0", type_of_assessment:, assessment_address_id: "UPRN-200000000004", type: "dec", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-5.0", type_of_assessment:, assessment_address_id: "RRN-0000-0000-0000-0000-0005", type: "dec", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0051", schema_type: "CEPC-5.1", type_of_assessment:, assessment_address_id: "UPRN-200000000051", type: "dec", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-6.0", type_of_assessment:, assessment_address_id: "UPRN-200000000006", type: "dec", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0020", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "dec", different_fields: {
      "postcode" => "SW10 0AA", "country_id": 3, "related_rrn" => "0000-0000-0000-0000-0021"
    })

    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_ni_search")
  end

  it "returns a dataset with the required data for dec CEPC 7.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0001" }
    expect(result).to eq expected_dec_7_data
  end

  it "returns a dataset with the required data for dec CEPC 7.1" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0002" }
    expect(result).to eq expected_dec_7_1_data
  end

  it "returns a dataset with the required data for dec CEPC 8.0.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0003" }
    expect(result).to eq expected_dec_8_data
  end

  it "returns a dataset with the required data for dec CEPC 4.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0004" }
    expect(result).to eq expected_dec_4_data
  end

  it "returns a dataset with the required data for dec CEPC 5.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0005" }
    expect(result).to eq expected_dec_5_data
  end

  it "returns a dataset with the required data for dec CEPC 6.0" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }
    expect(result).to eq expected_dec_6_data
  end

  it "does not return any DEC for NI" do
    expect(query_result.map { |i| i["certificate_number"] }).not_to include("0000-0000-0000-0000-0020")
  end

  context "when an assessment has a certificate_number value saved into the assessment_address_id attribute" do
    it "returns a nil value for the uprn" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0001" }["uprn"]).to be_nil
    end
  end

  context "when checking the columns of the materialized view" do
    let(:expected_columns) do
      %w[ac_inspection_commissioned address address1 address2 address3 aircon_kw_rating aircon_present annual_electrical_fuel_usage annual_thermal_fuel_usage building_category building_environment certificate_number constituency constituency_label country current_operational_rating electric_co2 estimated_aircon_kw_rating heating_co2 inspection_date local_authority local_authority_label lodgement_date lodgement_datetime main_benchmark main_heating_fuel nominated_date occupancy_level operational_rating_band or_assessment_end_date other_fuel postcode posttown property_type renewable_sources renewables_co2 renewables_electrical renewables_fuel_thermal report_type special_energy_uses total_floor_area typical_electrical_fuel_usage typical_thermal_fuel_usage typical_thermal_use uprn yr1_electricity_co2 yr1_heating_co2 yr1_operational_rating yr1_renewables_co2 yr2_electricity_co2 yr2_heating_co2 yr2_operational_rating yr2_renewables_co2 uprn_source]
    end

    it "returns the correct columns" do
      expect(mview_columns("mvw_dec_ni_search").sort.map(&:downcase)).to eq expected_columns.sort.map(&:downcase)
    end
  end
end
