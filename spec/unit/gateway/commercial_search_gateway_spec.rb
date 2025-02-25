require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe Gateway::CommercialSearchGateway do
  subject(:gateway) { described_class.new }

  context "when creating commercial materialized view" do
    include_context "when lodging XML"
    include_context "when saving ons data"
    include_context "when exporting data"
    before do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc")
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "CEPC-7.0", type_of_assessment: "CEPC", type: "cepc+rr")
    end

    let(:cepc_expected_data) do
      { "assessment_id" => "0000-0000-0000-0000-0006",
        "address1" => "60 Maple Syrup Road",
        "address2" => "Candy Mountain",
        "postcode" => "NE0 0AA",
        "region" => "Big Rock",
        "property_type" => "A1/A2 Retail and Financial/Professional services",
        "asset_rating" => "84",
        "building_reference_number" => "UPRN-000000000000",
        "asset_rating_band" => "D",
        "inspection_date" => "2021-03-19",
        "lodgement_date" => "2021-03-19",
        "transaction_type" => "1",
        "building_level" => "3",
        "existing_stock_benchmark" => "100",
        "main_heating_fuel" => "Grid Supplied Electricity",
        "new_build_benchmark" => "34",
        "ac_inspection_commissioned" => "4",
        "aircon_kw_rating" => "Unknown",
        "aircon_present" => "No",
        "floor_area" => "951",
        "lodgement_datetime" => Time.parse("2021-03-19 00:00:00.000000000 +0000"),
        "other_fuel_desc" => nil,
        "renewable_sources" => nil,
        "special_energy_uses" => nil,
        "standard_emissions" => "45.61",
        "building_emissions" => "76.29",
        "target_emissions" => "31.05",
        "typical_emissions" => "90.98",
        "building_environment" => "Air Conditioning",
        "country" => "England",
        "primary_energy_value" => "451.27",
        "report_type" => "3",
        "type_of_assessment" => "CEPC" }
    end

    let(:cepc_rr_expected_data) do
      {
        "ac_inspection_commissioned" => "4",
        "address1" => nil,
        "address2" => "Acme Coffee",
        "region" => "POSTTOWN",
        "aircon_kw_rating" => "Unknown",
        "aircon_present" => "No",
        "assessment_id" => "0000-0000-0000-0000-0007",
        "asset_rating" => "134",
        "asset_rating_band" => "F",
        "building_emissions" => "158.9",
        "building_environment" => "Heating and Natural Ventilation",
        "building_level" => "3",
        "building_reference_number" => "987345673489",
        "country" => "England",
        "existing_stock_benchmark" => "90",
        "floor_area" => "314",
        "inspection_date" => "2013-08-10",
        "lodgement_date" => "2013-08-15",
        "lodgement_datetime" => Time.parse("2013-08-15 00:00:00.000000000 +0000"),
        "main_heating_fuel" => "Grid Supplied Electricity",
        "new_build_benchmark" => "34",
        "other_fuel_desc" => nil,
        "postcode" => "PT42 7AD",
        "primary_energy_value" => nil,
        "property_type" => "A3/A4/A5 Restaurant and Cafes/Drinking Establishments and Hot Food takeaways",
        "renewable_sources" => nil,
        "report_type" => "3",
        "special_energy_uses" => nil,
        "standard_emissions" => "59.26",
        "target_emissions" => "39.95",
        "transaction_type" => "1",
        "type_of_assessment" => "CEPC",
        "typical_emissions" => "106.52",
      }
    end

    it "creates a table with the required data for cepc" do
      result = gateway.fetch("0000-0000-0000-0000-0006").first
      expect(result).to eq cepc_expected_data
    end

    it "creates a table with the required data for cepc+rr" do
      result = gateway.fetch("0000-0000-0000-0000-0007").first
      expect(result).to eq cepc_rr_expected_data
    end
  end
end
