require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_data_export"

describe "NI Commercial Recommendations Yesterday Report" do
  include_context "when lodging XML"
  include_context "when exporting data"

  before(:all) do
    add_countries

    type_of_assessment = "CEPC-RR"
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "cepc-rr", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0000"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "cepc-rr", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0003"
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", schema_type: "CEPC-7.1", type_of_assessment:, type: "cepc-rr", different_fields: {
      "postcode" => "BT10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0005"
    })
    add_commercial(assessment_id: "0000-0000-0000-0000-0010", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
      "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0011"
    })
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0001'", "SQL")
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0004'", "SQL")
    ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0010'", "SQL")
  end

  let(:expected_report) do
    [{ "certificate_number" => "0000-0000-0000-0000-0001",
       "payback_type" => "SHORT",
       "recommendation_item" => 1,
       "recommendation" => "Consider replacing T8 lamps with retrofit T5 conversion kit.",
       "recommendation_code" => "ECP-L5",
       "related_certificate_number" => "0000-0000-0000-0000-0000" },
     { "certificate_number" => "0000-0000-0000-0000-0001",
       "payback_type" => "SHORT",
       "recommendation_item" => 2,
       "recommendation" => "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
       "recommendation_code" => "EPC-L7",
       "related_certificate_number" => "0000-0000-0000-0000-0000" },
     { "certificate_number" => "0000-0000-0000-0000-0001",
       "payback_type" => "MEDIUM",
       "recommendation_item" => 3,
       "recommendation" => "Add optimum start/stop to the heating system.",
       "recommendation_code" => "EPC-H7",
       "related_certificate_number" => "0000-0000-0000-0000-0000" },
     { "certificate_number" => "0000-0000-0000-0000-0001",
       "payback_type" => "LONG",
       "recommendation_item" => 4,
       "recommendation" => "Consider installing an air source heat pump.",
       "recommendation_code" => "EPC-R5",
       "related_certificate_number" => "0000-0000-0000-0000-0000" },
     { "certificate_number" => "0000-0000-0000-0000-0001",
       "payback_type" => "OTHER",
       "recommendation_item" => 5,
       "recommendation" => "Consider installing PV.",
       "recommendation_code" => "EPC-R4",
       "related_certificate_number" => "0000-0000-0000-0000-0000" }]
  end
  let(:vw_yesterday) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM vw_commercial_ni_rr_yesterday ORDER BY certificate_number, recommendation_item").map { |row| row }
  end

  let(:mvw_columns) { get_columns_from_view("mvw_commercial_ni_rr_search") }
  let(:vw_columns) { get_columns_from_view("vw_commercial_ni_rr_yesterday") }

  context "when comparing mvw and vw columns" do
    it "returns the same columns" do
      expect(vw_columns).to eq mvw_columns
    end
  end

  it "returns data from yesterday" do
    result = vw_yesterday.map { |row| row["certificate_number"] }.uniq
    expect(result).to include "0000-0000-0000-0000-0001"
    expect(result).to include "0000-0000-0000-0000-0004"
  end

  it "returns the correct recommendations for a CEPC recommendation report" do
    result = vw_yesterday.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
    expect(result).to eq expected_report
  end

  it "does not return non-NI data from yesterday" do
    result = vw_yesterday.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0010" }
    expect(result).to eq []
  end
end
