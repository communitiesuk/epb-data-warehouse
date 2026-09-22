require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_data_export"

describe "DEC NI Recommendations Yesterday Report" do
  include_context "when lodging XML"
  include_context "when exporting data"

  context "when fetching data from vw_dec_ni_rr_yesterday" do
    before(:all) do
      add_countries
      yesterday = Date.today - 1

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
      add_commercial(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0000"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-5.1", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0002"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-6.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0004"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0011", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0010"
      })
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{yesterday}' WHERE assessment_id = '0000-0000-0000-0000-0001'", "SQL")
    end

    let(:expected_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation_item" => 1,
         "recommendation" => "Consider thinking about maybe possibly getting a solar panel but only one.",
         "recommendation_code" => "ECP-L5",
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation_item" => 2,
         "recommendation" => "Consider introducing variable speed drives (VSD) for fans, pumps and compressors.",
         "recommendation_code" => "EPC-L7",
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "MEDIUM",
         "recommendation_item" => 3,
         "recommendation" => "Engage experts to propose specific measures to reduce hot waterwastage and plan to carry this out.",
         "recommendation_code" => "ECP-C1",
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "LONG",
         "recommendation_item" => 4,
         "recommendation" => "Consider replacing or improving glazing",
         "recommendation_code" => "ECP-F4",
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "OTHER",
         "recommendation_item" => 5,
         "recommendation" => "Add a big wind turbine",
         "recommendation_code" => "ECP-H2",
         "related_certificate_number" => "0000-0000-0000-0000-0000" }]
    end

    let(:vw_yesterday) do
      ActiveRecord::Base.connection.exec_query("SELECT certificate_number, payback_type, recommendation_item, recommendation, recommendation_code, related_certificate_number
                        FROM vw_dec_ni_rr_yesterday ORDER BY certificate_number, recommendation_item").to_a
    end

    let(:mvw_columns) { get_columns_from_view("mvw_dec_ni_rr_search") }
    let(:vw_columns) { get_columns_from_view("vw_dec_ni_rr_yesterday") }

    context "when comparing mvw and vw columns" do
      it "returns the same columns" do
        expect(vw_columns).to eq mvw_columns
      end
    end

    it "returns data from yesterday from the lodged NI commercial dec data" do
      expect(vw_yesterday.length).to eq 5
      expect(vw_yesterday.map { |row| row["certificate_number"] }).to all(eq("0000-0000-0000-0000-0001"))
    end

    it "returns the correct recommendations for an NI recommendation report" do
      result = vw_yesterday.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
      expect(result).to eq expected_report
    end

    it "does not return a non-NI DEC-RR updated yesterday" do
      result = vw_yesterday.map { |row| row["certificate_number"] }
      expect(result).not_to include("0000-0000-0000-0000-0011")
    end
  end
end
