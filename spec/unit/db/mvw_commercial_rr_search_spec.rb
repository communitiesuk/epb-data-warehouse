require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Commercial Recommendations Report" do
  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  context "when fetching data from mvw_commercial_rr" do
    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
      schema_type = "CEPC-8.0.0"

      add_commercial(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-3.1", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-1000"
      })
      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")

      add_commercial(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-1001"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-5.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-1002"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-7.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-1003"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0008", schema_type: "CEPC-7.1", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-1008"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0005", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0004", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0006", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "CEPC", type: "cepc", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0007", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0007", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0006", registration_date: Time.now
      })

      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_rr_search")
    end

    let(:expected_50_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0002",
         "payback_type" => "SHORT",
         "recommendation" => "Consider replacing T8 lamps with retrofit T5 conversion kit.",
         "recommendation_code" => "ECP-L5",
         "recommendation_item" => 1,
         "related_certificate_number" => "0000-0000-0000-0000-1002" },
       { "certificate_number" => "0000-0000-0000-0000-0002",
         "payback_type" => "SHORT",
         "recommendation" => "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
         "recommendation_code" => "EPC-L7",
         "recommendation_item" => 2,
         "related_certificate_number" => "0000-0000-0000-0000-1002" },
       { "certificate_number" => "0000-0000-0000-0000-0002",
         "payback_type" => "MEDIUM",
         "recommendation" => "Add optimum start/stop to the heating system.",
         "recommendation_code" => "EPC-H7",
         "recommendation_item" => 3,
         "related_certificate_number" => "0000-0000-0000-0000-1002" },
       { "certificate_number" => "0000-0000-0000-0000-0002",
         "payback_type" => "LONG",
         "recommendation" => "Consider installing an air source heat pump.",
         "recommendation_code" => "EPC-R5",
         "recommendation_item" => 4,
         "related_certificate_number" => "0000-0000-0000-0000-1002" },
       { "certificate_number" => "0000-0000-0000-0000-0002",
         "payback_type" => "OTHER",
         "recommendation" => "Consider installing PV.",
         "recommendation_code" => "EPC-R4",
         "recommendation_item" => 5,
         "related_certificate_number" => "0000-0000-0000-0000-1002" }]
    end

    let(:expected_70_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0003",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Consider replacing T8 lamps with retrofit T5 conversion kit.",
         "recommendation_code" => "ECP-L5",
         "recommendation_item" => 1,
         "related_certificate_number" => "0000-0000-0000-0000-1003" },
       { "certificate_number" => "0000-0000-0000-0000-0003",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
         "recommendation_code" => "EPC-L7",
         "recommendation_item" => 2,
         "related_certificate_number" => "0000-0000-0000-0000-1003" },
       { "certificate_number" => "0000-0000-0000-0000-0003",
         "payback_type" => "MEDIUM",
         "recommendation" => "Add optimum start/stop to the heating system.",
         "recommendation_code" => "EPC-H7",
         "recommendation_item" => 3,
         "related_certificate_number" => "0000-0000-0000-0000-1003" },
       { "certificate_number" => "0000-0000-0000-0000-0003",
         "payback_type" => "LONG",
         "recommendation" => "Consider installing an air source heat pump.",
         "recommendation_code" => "EPC-R5",
         "recommendation_item" => 4,
         "related_certificate_number" => "0000-0000-0000-0000-1003" },
       { "certificate_number" => "0000-0000-0000-0000-0003",
         "payback_type" => "OTHER",
         "recommendation" => "Consider installing PV.",
         "recommendation_code" => "EPC-R4",
         "recommendation_item" => 5,
         "related_certificate_number" => "0000-0000-0000-0000-1003" }]
    end

    let(:expected_71_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0008",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
         "recommendation_code" => "EPC-L7",
         "recommendation_item" => 1,
         "related_certificate_number" => "0000-0000-0000-0000-1008" },
       { "certificate_number" => "0000-0000-0000-0000-0008",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Consider replacing T8 lamps with retrofit T5 conversion kit.",
         "recommendation_code" => "ECP-L5",
         "recommendation_item" => 2,
         "related_certificate_number" => "0000-0000-0000-0000-1008" },
       { "certificate_number" => "0000-0000-0000-0000-0008",
         "payback_type" => "MEDIUM",
         "recommendation" => "Add optimum start/stop to the heating system.",
         "recommendation_code" => "EPC-H7",
         "recommendation_item" => 3,
         "related_certificate_number" => "0000-0000-0000-0000-1008" },
       { "certificate_number" => "0000-0000-0000-0000-0008",
         "payback_type" => "LONG",
         "recommendation" => "Consider installing an air source heat pump.",
         "recommendation_code" => "EPC-R5",
         "recommendation_item" => 4,
         "related_certificate_number" => "0000-0000-0000-0000-1008" },
       { "certificate_number" => "0000-0000-0000-0000-0008",
         "payback_type" => "OTHER",
         "recommendation" => "Consider installing PV.",
         "recommendation_code" => "EPC-R4",
         "recommendation_item" => 5,
         "related_certificate_number" => "0000-0000-0000-0000-1008" }]
    end

    let(:expected_800_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation_item" => 1,
         "recommendation" => "Consider replacing T8 lamps with retrofit T5 conversion kit.",
         "recommendation_code" => "ECP-L5",
         "related_certificate_number" => "0000-0000-0000-0000-1001" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation_item" => 2,
         "recommendation" => "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
         "recommendation_code" => "EPC-L7",
         "related_certificate_number" => "0000-0000-0000-0000-1001" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "MEDIUM",
         "recommendation_item" => 3,
         "recommendation" => "Add optimum start/stop to the heating system.",
         "recommendation_code" => "EPC-H7",
         "related_certificate_number" => "0000-0000-0000-0000-1001" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "LONG",
         "recommendation_item" => 4,
         "recommendation" => "Consider installing an air source heat pump.",
         "recommendation_code" => "EPC-R5",
         "related_certificate_number" => "0000-0000-0000-0000-1001" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "OTHER",
         "recommendation_item" => 5,
         "recommendation" => "Consider installing PV.",
         "recommendation_code" => "EPC-R4",
         "related_certificate_number" => "0000-0000-0000-0000-1001" }]
    end

    let(:data) do
      ActiveRecord::Base.connection.exec_query("SELECT certificate_number,payback_type,recommendation_item, recommendation,recommendation_code, related_certificate_number
                        FROM mvw_commercial_rr_search ORDER BY certificate_number, recommendation_item").map { |row| row }
    end

    context "when the schema version is CEPC-8.0" do
      it "returns only the cepc-rr from the lodged commercial data" do
        expect(data.length).to eq 25
      end

      it "returns the correct recommendations for a CEPC-8.0.0 recommendation reports" do
        result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
        expect(result.length).to eq 5
        expect(result).to eq expected_800_report
      end

      it "returns the correct recommendations for a CEPC-5.0 recommendation reports" do
        result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0002" }
        expect(result.length).to eq 5
        expect(result).to eq expected_50_report
      end

      it "returns the correct recommendations for a CEPC-7.1 recommendation reports" do
        result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0008" }
        expect(result.length).to eq 5

        expect(result.map { |row| row.except("recommendation_item") })
          .to match_array(expected_71_report.map { |row| row.except("recommendation_item") })
      end

      it "returns the correct recommendations for a CEPC-7.0 recommendation reports" do
        result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0003" }
        expect(result.length).to eq 5

        expect(result.map { |row| row.except("recommendation_item") })
          .to match_array(expected_70_report.map { |row| row.except("recommendation_item") })
      end

      it "returns the recommendations for 5 CEPC-RR" do
        result = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT certificate_number FROM mvw_commercial_rr_search ORDER BY certificate_number").map { |row| row["certificate_number"] }
        expect(result).to eq %w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001 0000-0000-0000-0000-0002 0000-0000-0000-0000-0003 0000-0000-0000-0000-0008]
      end

      it "the reports contains the certificate numbers of the related CEPC" do
        result = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT related_certificate_number FROM mvw_commercial_rr_search ORDER BY related_certificate_number").map { |row| row["related_certificate_number"] }
        expect(result).to eq %w[0000-0000-0000-0000-1000 0000-0000-0000-0000-1001 0000-0000-0000-0000-1002 0000-0000-0000-0000-1003 0000-0000-0000-0000-1008]
      end

      it "does not return recommendations for NI CEPC-RR" do
        result = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT certificate_number FROM mvw_commercial_rr_search ORDER BY certificate_number").map { |row| row["certificate_number"] }
        expect(result).not_to include("0000-0000-0000-0000-0007")
      end
    end

    context "when the schema version is CEPC-7.0" do
      before do
        schema_type = "CEPC-7.0"
        add_commercial(assessment_id: "0000-0000-0000-0000-0098", schema_type:, type_of_assessment: "CEPC", type: "cepc", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0099", registration_date: Time.now
        })
        add_commercial(assessment_id: "0000-0000-0000-0000-0099", schema_type:, type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0098"
        })
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_rr_search")
      end

      it "returns the correct recommendations for payback other" do
        result = data.find { |row| row["certificate_number"] == "0000-0000-0000-0000-0099" && row["recommendation_item"] == 5 }
        expect(result["payback_type"]).to eq "OTHER"
        expect(result["recommendation"]).to eq "Consider installing PV."
        expect(result["related_certificate_number"]).to eq "0000-0000-0000-0000-0098"
      end
    end
  end
end
