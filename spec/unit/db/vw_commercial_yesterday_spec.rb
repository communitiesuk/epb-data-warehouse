require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Domestic Report Yesterday" do
  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }
  let(:search_arguments) do
    { date_start:, date_end: }
  end

  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data
    add_countries
    type_of_assessment = "CEPC"

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-8.0.0", type_of_assessment:, type: "cepc", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-7.0", type_of_assessment:, type: "cepc+rr", add_to_assessment_search: true, different_fields: {
      "postcode" => "SW10 0AA", "country_id": 1
    })
  end

  context "when calling vw_domestic_yesterday" do
    let(:mvw_columns) { get_columns_from_view("mvw_commercial_search") }
    let(:vw_columns) { get_columns_from_view("vw_commercial_yesterday") }

    let(:vw_yesterday) { ActiveRecord::Base.connection.exec_query("SELECT * FROM vw_commercial_yesterday", "SQL").map { |result| result } }

    let(:yesterday) { (Date.today - 1) }

    before do
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{yesterday}' WHERE assessment_id = '0000-0000-0000-0000-0001'", "SQL")
    end

    it "returns the same columns as the mvw_commercial_search" do
      expect(vw_columns).to eq mvw_columns
    end

    it "returns only the commercial data from yesterday" do
      expect(vw_yesterday.length).to eq 1
      expect(vw_yesterday[0]["certificate_number"]).to eq("0000-0000-0000-0000-0001")
    end

    it "includes rows updated yesterday" do
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_documents SET updated_at = '#{yesterday}' WHERE assessment_id = '0000-0000-0000-0000-0002'", "SQL")
      expect(vw_yesterday.map { |i| i["certificate_number"] }.sort!).to eq %w[0000-0000-0000-0000-0001 0000-0000-0000-0000-0002]
    end
  end
end
