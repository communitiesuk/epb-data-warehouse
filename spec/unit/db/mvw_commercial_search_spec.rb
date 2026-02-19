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
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_commercial_search")
  end
  let(:cepc_expected_data) do
    { "certificate_number" => "0000-0000-0000-0000-0006",
      "estimated_aircon_kw_rating" => "3",
      "address1" => "60 Maple Syrup Road",
      "address2" => "Candy Mountain",
      "address3" => nil,
      "postcode" => "SW10 0AA",
      "posttown" => "Big Rock",
      "property_type" => "A1/A2 Retail and Financial/Professional services",
      "asset_rating" => "84",
      "uprn" => nil,
      "asset_rating_band" => "D",
      "inspection_date" => "2021-03-19",
      "local_authority" => "E09000013",
      "local_authority_label" => "Hammersmith and Fulham",
      "lodgement_date" => "2021-03-19",
      "transaction_type" => "Mandatory issue (Marketed sale).",
      "building_level" => "3",
      "existing_stock_benchmark" => "100",
      "main_heating_fuel" => "Grid Supplied Electricity",
      "new_build_benchmark" => "34",
      "ac_inspection_commissioned" => "4",
      "address" => "60 Maple Syrup Road",
      "aircon_kw_rating" => "100",
      "aircon_present" => "No",
      "floor_area" => "951",
      "lodgement_datetime" => Time.parse("2021-07-21 11:26:28.045000000 +0000"),
      "other_fuel_desc" => "Other fuel test",
      "renewable_sources" => "Renewable sources test",
      "special_energy_uses" => "Test sp",
      "standard_emissions" => "45.61",
      "building_emissions" => "76.29",
      "target_emissions" => "31.05",
      "typical_emissions" => "90.98",
      "building_environment" => "Air Conditioning",
      "constituency" => "E14000629",
      "constituency_label" => "Chelsea and Fulham",
      "primary_energy_value" => "451.27",
      "report_type" => "3",
      "uprn_source" => nil }
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries

    type_of_assessment = "CEPC"

    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "cepc", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0007"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0009", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "cepc", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "related_rrn" => "0000-0000-0000-0000-0006", "country_id": 1, "assessment_address_id" => "UPRN-000000000000"
    })

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "CEPC-7.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "related_rrn" => "0000-0000-0000-0000-0006", "country_id": 1, "assessment_address_id" => "UPRN-000000000000"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", add_to_assessment_search: true, different_fields: {
      "postcode": "SW10 0AA", "country_id": 2
    })
    import_look_ups(schema_versions: %w[CEPC-8.0.0 CEPC-7.0])
    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_search")
  end

  it "returns a dataset with 2 commercial EPCs" do
    expect(query_result.length).to eq 2
  end

  it "returns a the expected data for a CEPC" do
    result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }
    expect(result).to eq cepc_expected_data
  end

  context "when an assessment has a URPN value in the assessment_address_id attribute" do
    it "returns a value for the uprn_source" do
      expect(query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0009" }["uprn_source"]).to eq "Energy Assessor"
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
      expect(commercial_reports_result.length).to eq 2
      expect(commercial_reports_result.first["assessment_id"]).to eq "0000-0000-0000-0000-0006"
    end

    it "inserts a new commercial report record with the correct related_certificate_number" do
      expect(commercial_reports_result.first["related_rrn"]).to eq "0000-0000-0000-0000-0007"
    end
  end
end
