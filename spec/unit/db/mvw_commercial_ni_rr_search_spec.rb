require_relative "../../shared_context/shared_lodgement"

describe "Commercial NI Recommendation Report Search" do
  include_context "when lodging XML"

  context "when fetching data from commercial recommendation reports for NI" do
    before(:all) do
      add_countries

      type_of_assessment = "CEPC-RR"

      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-NI-8.0.0", type_of_assessment:, type: "cepc-rr", different_fields: {
        "postcode" => "BT10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0000"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-7.1", type_of_assessment:, type: "cepc-rr", different_fields: {
        "postcode" => "BT10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0003"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", schema_type: "CEPC-4.0", type_of_assessment:, type: "cepc-rr", different_fields: {
        "postcode" => "BT10 0AA", "country_id": 3
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0010", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0011"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0012", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC-RR", type: "cepc-rr", different_fields: {
        "postcode": "LL3 0AA", "country_id": 2, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0013"
      })

      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_commercial_ni_rr_search")
    end

    let(:data) do
      ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_commercial_ni_rr_search ORDER BY certificate_number, recommendation_item").map { |row| row }
    end

    let(:expected_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Consider replacing T8 lamps with retrofit T5 conversion kit.",
         "recommendation_code" => "ECP-L5",
         "recommendation_item" => 1,
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "SHORT",
         "recommendation" =>
              "Introduce HF (high frequency) ballasts for fluorescent tubes: Reduced number of fittings required.",
         "recommendation_code" => "EPC-L7",
         "recommendation_item" => 2,
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "MEDIUM",
         "recommendation" => "Add optimum start/stop to the heating system.",
         "recommendation_code" => "EPC-H7",
         "recommendation_item" => 3,
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "LONG",
         "recommendation" => "Consider installing an air source heat pump.",
         "recommendation_code" => "EPC-R5",
         "recommendation_item" => 4,
         "related_certificate_number" => "0000-0000-0000-0000-0000" },
       { "certificate_number" => "0000-0000-0000-0000-0001",
         "payback_type" => "OTHER",
         "recommendation" => "Consider installing PV.",
         "recommendation_code" => "EPC-R4",
         "recommendation_item" => 5,
         "related_certificate_number" => "0000-0000-0000-0000-0000" }]
    end

    it "returns all the recommendations from the lodged commercial data" do
      expect(data.length).to eq 15
    end

    it "returns the correct recommendations for a CEPC recommendation reports" do
      result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0001" }
      expect(result).to eq expected_report
    end

    it "does not return recommendations for a non-NI CEPC" do
      result = data.select { |row| %w[0000-0000-0000-0000-0010 0000-0000-0000-0000-0012].include?(row["certificate_number"]) }
      expect(result).to eq []
    end
  end
end
