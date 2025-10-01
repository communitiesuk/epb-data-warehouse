require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_import_enums"

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
    include_context "when saving enum data to lookup tables"

    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries

      type_of_assessment = "CEPC"

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "cepc", add_to_assessment_search: true, different_fields: {
        "postcode" => "SW10 0AA", "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0007"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0007", schema_type: "CEPC-7.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", add_to_assessment_search: true, different_fields: {
        "postcode" => "SW10 0AA", "related_rrn" => "0000-0000-0000-0000-0006", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", add_to_assessment_search: true, different_fields: {
        "postcode": "SW10 0AA", "country_id": 2
      })
      import_look_ups(schema_versions: %w[CEPC-8.0.0 CEPC-7.0])
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_search")
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
        "report_type" => "3" }
    end

    let(:query_result) do
      gateway.fetch(**search_arguments)
    end

    it "returns a dataset with only one commercial EPCs" do
      expect(query_result.length).to eq 1
    end

    it "returns a dataset with the required data for cepc" do
      result = query_result.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }
      expect(result).to eq cepc_expected_data
    end

    context "when an assessment has a certificate_number value saved into the assessment_address_id attribute" do
      it "returns a nil value for the uprn" do
        results = gateway.fetch(**search_arguments)
        expect(results.find { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }["uprn"]).to be_nil
      end
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

    context "when checking commercial_reports table" do
      let(:commercial_reports_result) do
        ActiveRecord::Base.connection.exec_query(
          "SELECT * FROM commercial_reports",
        )
      end

      it "inserts a new commercial report record" do
        expect(commercial_reports_result.length).to eq 1
        expect(commercial_reports_result.first["assessment_id"]).to eq "0000-0000-0000-0000-0006"
      end

      it "inserts a new commercial report record with the correct related_certificate_number" do
        expect(commercial_reports_result.first["related_rrn"]).to eq "0000-0000-0000-0000-0007"
      end
    end
  end
end
