require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "DEC Recommendations Report" do
  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  context "when fetching data from mvw_dec_rr_search" do
    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries
      schema_type = "CEPC-8.0.0"

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
      add_commercial(assessment_id: "0000-0000-0000-0000-0000", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0001", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0001", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0000"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0002", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0003", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0003", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0002"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0004", schema_type:, type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0005", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0005", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0004", registration_date: Time.now
      })

      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_rr_search")
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

    let(:data) do
      ActiveRecord::Base.connection.exec_query("SELECT certificate_number,payback_type,recommendation_item, recommendation,recommendation_code, related_certificate_number
                        FROM mvw_dec_rr_search ORDER BY certificate_number, recommendation_item").map { |row| row }
    end

    context "when the schema version is CEPC-8.0" do
      it "returns only the dec-rr from the lodged commercial dec data" do
        expect(data.length).to eq 10
      end

      it "returns the correct recommendations for a DEC recommendation reports" do
        result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
        expect(result.length).to eq 5
        expect(result).to eq expected_report
      end

      it "returns the recommendations for only two DEC-RR" do
        result = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT certificate_number FROM mvw_dec_rr_search ORDER BY certificate_number").map { |row| row["certificate_number"] }
        expect(result).to eq %w[0000-0000-0000-0000-0001 0000-0000-0000-0000-0003]
      end

      it "the reports contains the certificate numbers of the related DEC" do
        result = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT related_certificate_number FROM mvw_dec_rr_search ORDER BY related_certificate_number").map { |row| row["related_certificate_number"] }
        expect(result).to eq %w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0002]
      end
    end

    context "when the schema version is CEPC-7.1" do
      before do
        schema_type = "CEPC-7.1"
        add_commercial(assessment_id: "0000-0000-0000-0000-0008", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0009", registration_date: Time.now
        })
        add_commercial(assessment_id: "0000-0000-0000-0000-0009", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0008"
        })
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_rr_search")
      end

      let(:report) do
        expected_report.map { |i| i.merge("certificate_number" => "0000-0000-0000-0000-0009", "related_certificate_number" => "0000-0000-0000-0000-0008") }
      end

      it "returns the correct recommendation for payback short" do
        result = data.find { |row| row["certificate_number"] == "0000-0000-0000-0000-0009" && row["recommendation_code"] == "ECP-L5" }
        expect(result["payback_type"]).to eq "SHORT"
        expect(result["recommendation"]).to eq "Consider thinking about maybe possibly getting a solar panel but only one."
        expect(result["related_certificate_number"]).to eq "0000-0000-0000-0000-0008"
      end
    end

    context "when the schema version is CEPC-7.0" do
      before do
        schema_type = "CEPC-7.0"
        add_commercial(assessment_id: "0000-0000-0000-0000-0098", schema_type:, type_of_assessment: "DEC", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, "related_rrn": "0000-0000-0000-0000-0099", registration_date: Time.now
        })
        add_commercial(assessment_id: "0000-0000-0000-0000-0099", schema_type:, type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
          "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0098"
        })
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_rr_search")
      end

      let(:report) do
        expected_report.map { |i| i.merge("certificate_number" => "0000-0000-0000-0000-0099", "related_certificate_number" => "0000-0000-0000-0000-0098") }
      end

      it "returns the correct recommendations for payback other" do
        result = data.find { |row| row["certificate_number"] == "0000-0000-0000-0000-0099" && row["recommendation_item"] == 5 }
        expect(result["payback_type"]).to eq "OTHER"
        expect(result["recommendation"]).to eq "Add a big wind turbine"
        expect(result["related_certificate_number"]).to eq "0000-0000-0000-0000-0098"
      end
    end
  end
end
