require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

describe "DEC Report" do
  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_dec_search")
  end
  let(:expected_dec_7_data) do
    { "certificate_number" => "0000-0000-0000-0000-0001",
      "constituency" => "E14000629",
      "constituency_label" => "Chelsea and Fulham",
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
      "country" => "England",
      "current_operational_rating" => "77",
      "electric_co2" => "163",
      "estimated_aircon_kw_rating" => "2",
      "heating_co2" => "153",
      "inspection_date" => "2016-04-11",
      "local_authority" => "E09000013",
      "local_authority_label" => "Hammersmith and Fulham",
      "lodgement_date" => "2016-04-25",
      "lodgement_datetime" => Time.parse("2021-07-21 11:26:28.045000000 +0000"),
      "main_benchmark" => "Schools And Seasonal Public Buildings",
      "main_heating_fuel" => "Natural Gas",
      "nominated_date" => "2016-02-23",
      "occupancy_level" => "Extended Occupancy",
      "operational_rating_band" => "D",
      "or_assessment_end_date" => "2016-01-01",
      "other_fuel" => nil,
      "postcode" => "SW10 0AA",
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
      "yr2_renewables_co2" => "0" }
  end
  let(:expected_dec_7_1_data) do
    expected_dec_7_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0002",
      "constituency" => "E14000629",
      "constituency_label" => "Chelsea and Fulham",
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
      "local_authority" => "E09000013",
      "local_authority_label" => "Hammersmith and Fulham",
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
  let(:expected_dec_8_data) do
    expected_dec_7_data.merge(
      "certificate_number" => "0000-0000-0000-0000-0003",
      "constituency" => "E14000629",
      "constituency_label" => "Chelsea and Fulham",
      "ac_inspection_commissioned" => "1",
      "address1" => "Some Unit",
      "address2" => "2 Lonely Street",
      "address3" => "Some Area",
      "address" => "Some Unit, 2 Lonely Street, Some Area",
      "aircon_kw_rating" => "1",
      "annual_electrical_fuel_usage" => 1,
      "annual_thermal_fuel_usage" => 1,
      "building_category" => "C1",
      "building_environment" => "Heating and Natural Ventilation",
      "current_operational_rating" => "1",
      "electric_co2" => "7",
      "estimated_aircon_kw_rating" => "1",
      "heating_co2" => "3",
      "inspection_date" => "2020-05-04",
      "local_authority" => "E09000013",
      "local_authority_label" => "Hammersmith and Fulham",
      "lodgement_date" => "2020-05-04",
      "main_benchmark" => nil,
      "nominated_date" => "2020-01-01",
      "occupancy_level" => "level",
      "operational_rating_band" => "A",
      "or_assessment_end_date" => "2020-05-01",
      "other_fuel" => "other",
      "posttown" => "Whitbury",
      "property_type" => "B1 Offices and Workshop businesses",
      "renewables_electrical" => "1",
      "renewables_fuel_thermal" => "1",
      "special_energy_uses" => "special",
      "total_floor_area" => 99,
      "typical_electrical_fuel_usage" => "1",
      "typical_thermal_fuel_usage" => 1,
      "typical_thermal_use" => 1,
      "yr1_electricity_co2" => "10",
      "yr1_heating_co2" => "5",
      "yr1_operational_rating" => "24",
      "yr1_renewables_co2" => "1",
      "yr2_electricity_co2" => "15",
      "yr2_heating_co2" => "10",
      "yr2_operational_rating" => "40",
      "yr2_renewables_co2" => "2",
    )
  end

  include_context "when saving enum data to lookup tables"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries
    type_of_assessment = "DEC"

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-7.0", type_of_assessment:, type: "dec+rr", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0004"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-7.1", type_of_assessment:, type: "dec+rr", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0005"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "dec", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0006"
    })

    import_look_ups(schema_versions: %w[CEPC-8.0.0 CEPC-7.0])
    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_search")
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

  context "when an assessment has a certificate_number value saved into the assessment_address_id attribute" do
    it "returns a nil value for the uprn" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0001" }["uprn"]).to be_nil
    end
  end

  context "when checking the columns of the materialized view" do
    let(:csv_fixture) { read_csv_fixture("dec") }

    it "returns the correct columns" do
      expect(csv_fixture.headers.sort.map(&:downcase) - expected_dec_7_data.keys).to eq []
      expect(expected_dec_7_data.keys - csv_fixture.headers.sort.map(&:downcase)).to eq []
    end
  end
end
