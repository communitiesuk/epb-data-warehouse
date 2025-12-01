require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "DEC Recommendations Yesterday Report" do
  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  context "when fetching data from vw_dec_yesterday_rr" do
    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
      schema_type = "CEPC-8.0.0"

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
      add_commercial(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0001"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0000"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0003"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0002"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0005"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0004"
      })
      ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0001'", "SQL")
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
      ActiveRecord::Base.connection.exec_query("SELECT certificate_number,payback_type,recommendation_item, recommendation,recommendation_code, related_certificate_number
                        FROM vw_dec_rr_yesterday ORDER BY certificate_number, recommendation_item").map { |row| row }
    end

    let(:mvw_columns) { get_columns_from_view("mvw_dec_rr_search") }
    let(:vw_columns) { get_columns_from_view("vw_dec_rr_yesterday") }

    context "when comparing mvw and vw columns" do
      it "returns the same columns" do
        expect(vw_columns).to eq mvw_columns
      end
    end

    context "when the schema version is CEPC-8.0" do
      it "returns data from yesterday from the lodged commercial dec data" do
        expect(vw_yesterday.length).to eq 5
        expect(vw_yesterday.map { |row| row["certificate_number"] }).to all(eq("0000-0000-0000-0000-0001"))
      end

      it "returns the correct recommendations for a CEPC recommendation report" do
        result = vw_yesterday.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
        expect(result).to eq expected_report
      end
    end

    context "when the schema version is CEPC-7.1" do
      before do
        schema_type = "CEPC-7.1"
        add_commercial(assessment_id: "0000-0000-0000-0000-0006", schema_type:, type_of_assessment: "DEC", type: "cepc-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0007"
        })
        add_commercial(assessment_id: "0000-0000-0000-0000-0007", schema_type:, type_of_assessment: "DEC-RR", type: "cepc-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0006"
        })
        ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0007'", "SQL")
      end

      let(:report) do
        expected_report.map { |i| i.merge("certificate_number" => "0000-0000-0000-0000-0007", "related_certificate_number" => "0000-0000-0000-0000-0006") }
      end

      it "returns the correct recommendation for payback short" do
        result = vw_yesterday.find { |row| row["certificate_number"] == "0000-0000-0000-0000-0007" && row["recommendation_code"] == "ECP-L5" }
        expect(result["payback_type"]).to eq "SHORT"
        expect(result["recommendation"]).to eq "Consider replacing T8 lamps with retrofit T5 conversion kit."
        expect(result["related_certificate_number"]).to eq "0000-0000-0000-0000-0006"
      end
    end

    context "when the schema version is CEPC-7.0" do
      before do
        schema_type = "CEPC-7.0"
        add_commercial(assessment_id: "0000-0000-0000-0000-0008", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0009", registration_date: Time.now
        })
        add_commercial(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0008"
        })
        ActiveRecord::Base.connection.exec_query("UPDATE assessment_search SET created_at = '#{Date.today - 1}' WHERE assessment_id = '0000-0000-0000-0000-0009'", "SQL")
      end

      let(:report) do
        expected_report.map { |i| i.merge("certificate_number" => "0000-0000-0000-0000-0009", "related_certificate_number" => "0000-0000-0000-0000-0008") }
      end

      it "returns the correct recommendations for payback other" do
        result = vw_yesterday.find { |row| row["certificate_number"] == "0000-0000-0000-0000-0009" && row["recommendation_item"] == 5 }
        expect(result["payback_type"]).to eq "OTHER"
        expect(result["recommendation"]).to eq "Add a big wind turbine"
        expect(result["related_certificate_number"]).to eq "0000-0000-0000-0000-0008"
      end
    end
  end
end
