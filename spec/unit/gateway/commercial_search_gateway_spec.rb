require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe Gateway::CommercialSearchGateway do
  subject(:gateway) { described_class.new }

  let(:date_start) { "2012-01-01" }
  let(:date_end) { "2022-01-01" }
  let(:search_arguments) do
    { date_start:, date_end: }
  end

  context "when creating commercial materialized view" do
    include_context "when lodging XML"
    include_context "when saving ons data"
    include_context "when exporting data"

    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
      config_path = "spec/config/attribute_enum_commercial_search_map.json"
      config_gateway = Gateway::XsdConfigGateway.new(config_path)
      import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
      import_use_case.execute
      type_of_assessment = "CEPC"

      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "cepc", different_fields: {
        "postcode" => "SW10 0AA",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "CEPC-7.0", type_of_assessment:, type: "cepc+rr", different_fields: {
        "postcode" => "SW10 0AA",
      })
      add_assessment(assessment_id: "0000-0000-0000-0000-0001", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", different_fields: {
        "postcode": "SW10 0AA",
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_search")
    end

    let(:cepc_expected_data) do
      { "rrn" => "0000-0000-0000-0000-0006",
        "estimated_aircon_kw_rating" => "3",
        "address1" => "60 Maple Syrup Road",
        "address2" => "Candy Mountain",
        "address3" => nil,
        "region" => "London",
        "postcode" => "SW10 0AA",
        "posttown" => "Big Rock",
        "property_type" => "A1/A2 Retail and Financial/Professional services",
        "asset_rating" => "84",
        "building_reference_number" => "UPRN-000000000000",
        "asset_rating_band" => "D",
        "inspection_date" => "2021-03-19",
        "lodgement_date" => "2021-03-19",
        "transaction_type" => "Mandatory issue (Marketed sale).",
        "building_level" => "3",
        "existing_stock_benchmark" => "100",
        "main_heating_fuel" => "Grid Supplied Electricity",
        "new_build_benchmark" => "34",
        "ac_inspection_commissioned" => "4",
        "aircon_kw_rating" => "100",
        "aircon_present" => "No",
        "floor_area" => "951",
        "lodgement_datetime" => Time.parse("2021-03-19 00:00:00.000000000 +0000"),
        "other_fuel_desc" => "Other fuel test",
        "renewable_sources" => "Renewable sources test",
        "special_energy_uses" => "Test sp",
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
        "estimated_aircon_kw_rating" => nil,
        "address1" => nil,
        "address2" => "Acme Coffee",
        "address3" => "13 Old Street",
        "region" => "London",
        "posttown" => "POSTTOWN",
        "aircon_kw_rating" => "",
        "aircon_present" => "No",
        "rrn" => "0000-0000-0000-0000-0007",
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
        "postcode" => "SW10 0AA",
        "primary_energy_value" => nil,
        "property_type" => "A3/A4/A5 Restaurant and Cafes/Drinking Establishments and Hot Food takeaways",
        "renewable_sources" => nil,
        "report_type" => "3",
        "special_energy_uses" => nil,
        "standard_emissions" => "59.26",
        "target_emissions" => "39.95",
        "transaction_type" => "Mandatory issue (Marketed sale).",
        "type_of_assessment" => "CEPC",
        "typical_emissions" => "106.52",
      }
    end

    let(:query_result) do
      gateway.fetch(**search_arguments)
    end

    it "returns a dataset with onl the 2 commercial EPCs" do
      expect(query_result.length).to eq 2
    end

    it "returns a dataset with the required data for cepc" do
      result = query_result.find { |i| i["rrn"] == "0000-0000-0000-0000-0006" }
      expect(result).to eq cepc_expected_data
    end

    it "returns a dataset with the required data for cepc+rr" do
      result = query_result.find { |i| i["rrn"] == "0000-0000-0000-0000-0007" }
      expect(result).to eq cepc_rr_expected_data
    end

    context "when checking the columns of the materialized view" do
      let(:csv_fixture) { read_csv_fixture("commercial") }

      let(:query_result) do
        search_arguments[:date_start] = "2020-04-04"
        gateway.fetch(**search_arguments)
      end

      it "returns the correct columns" do
        expect(csv_fixture.headers.sort.map(&:downcase) - cepc_expected_data.keys).to eq []
      end
    end
  end
end
