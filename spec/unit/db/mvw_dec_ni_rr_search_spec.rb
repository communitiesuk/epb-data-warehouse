require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"

describe "DEC NI Recommendations Report" do
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  context "when fetching data from mvw_dec_ni_rr_search" do
    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      add_countries

      ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
      add_commercial(assessment_id: "0000-0000-0000-0000-0000", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0001", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0000"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-4.0", type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0003", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-5.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0002"
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0004", schema_type: "CEPC-5.1", type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0005", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-6.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "SW10 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0004", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0010", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC", type: "dec", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, "related_rrn": "0000-0000-0000-0000-0011", registration_date: Time.now
      })
      add_commercial(assessment_id: "0000-0000-0000-0000-0011", schema_type: "CEPC-NI-8.0.0", type_of_assessment: "DEC-RR", type: "dec-rr", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3, registration_date: Time.now, "related_rrn": "0000-0000-0000-0000-0010"
      })

      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_dec_ni_rr_search")
    end

    let(:expected_ni_60_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0005",
         "payback_type" => "SHORT",
         "recommendation" => "Consider thinking about maybe possibly getting a solar panel but only one.",
         "recommendation_code" => "ECP-L5",
         "recommendation_item" => 1,
         "related_certificate_number" => "0000-0000-0000-0000-0004" },
       { "certificate_number" => "0000-0000-0000-0000-0005",
         "payback_type" => "SHORT",
         "recommendation" => "Consider introducing variable speed drives (VSD) for fans, pumps and compressors.",
         "recommendation_code" => "EPC-L7",
         "recommendation_item" => 2,
         "related_certificate_number" => "0000-0000-0000-0000-0004" },
       { "certificate_number" => "0000-0000-0000-0000-0005",
         "payback_type" => "MEDIUM",
         "recommendation" => "Engage experts to propose specific measures to reduce hot waterwastage and plan to carry this out.",
         "recommendation_code" => "ECP-C1",
         "recommendation_item" => 3,
         "related_certificate_number" => "0000-0000-0000-0000-0004" },
       { "certificate_number" => "0000-0000-0000-0000-0005",
         "payback_type" => "LONG",
         "recommendation" => "Consider replacing or improving glazing",
         "recommendation_code" => "ECP-F4",
         "recommendation_item" => 4,
         "related_certificate_number" => "0000-0000-0000-0000-0004" },
       { "certificate_number" => "0000-0000-0000-0000-0005",
         "payback_type" => "OTHER",
         "recommendation" => "Add a big wind turbine",
         "recommendation_code" => "ECP-H2",
         "recommendation_item" => 5,
         "related_certificate_number" => "0000-0000-0000-0000-0004" }]
    end
    let(:expected_ni_800_report) do
      [{ "certificate_number" => "0000-0000-0000-0000-0011",
         "payback_type" => "SHORT",
         "recommendation_item" => 1,
         "recommendation" => "Consider introducing variable speed drives (VSD) for fans, pumps and compressors.",
         "recommendation_code" => "EPC-L7",
         "related_certificate_number" => "0000-0000-0000-0000-0010" },
       { "certificate_number" => "0000-0000-0000-0000-0011",
         "payback_type" => "SHORT",
         "recommendation_item" => 2,
         "recommendation" => "Consider thinking about maybe possibly getting a solar panel but only one.",
         "recommendation_code" => "ECP-L5",
         "related_certificate_number" => "0000-0000-0000-0000-0010" },
       { "certificate_number" => "0000-0000-0000-0000-0011",
         "payback_type" => "MEDIUM",
         "recommendation_item" => 3,
         "recommendation" => "Engage experts to propose specific measures to reduce hot waterwastage and plan to carry this out.",
         "recommendation_code" => "ECP-C1",
         "related_certificate_number" => "0000-0000-0000-0000-0010" },
       { "certificate_number" => "0000-0000-0000-0000-0011",
         "payback_type" => "LONG",
         "recommendation_item" => 4,
         "recommendation" => "Consider replacing or improving glazing",
         "recommendation_code" => "ECP-F4",
         "related_certificate_number" => "0000-0000-0000-0000-0010" },
       { "certificate_number" => "0000-0000-0000-0000-0011",
         "payback_type" => "OTHER",
         "recommendation_item" => 5,
         "recommendation" => "Add a big wind turbine",
         "recommendation_code" => "ECP-H2",
         "related_certificate_number" => "0000-0000-0000-0000-0010" }]
    end

    let(:data) do
      ActiveRecord::Base.connection.exec_query("SELECT certificate_number, payback_type, recommendation_item, recommendation, recommendation_code, related_certificate_number
                        FROM mvw_dec_ni_rr_search ORDER BY certificate_number, recommendation_item").to_a
    end

    let(:certificate_numbers) do
      data.map { |row| row["certificate_number"] }.uniq
    end

    let(:related_certificate_numbers) do
      data.map { |row| row["related_certificate_number"] }.uniq
    end

    it "returns only the NI DEC-RR rows from the lodged commercial data" do
      expect(data.length).to eq 20
    end

    it "returns the correct recommendations for the NI DEC with schema_type CEPC-NI-8.0.0 recommendation report" do
      result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0011" }
      expect(result.length).to eq 5
      expect(result).to eq expected_ni_800_report
    end

    it "returns the correct recommendations for the NI DEC with schema_type CEPC-NI-6.0 recommendation report" do
      result = data.select { |row| row["certificate_number"] == "0000-0000-0000-0000-0005" }
      expect(result.length).to eq 5
      expect(result).to eq expected_ni_60_report
    end

    it "returns only the NI DEC-RR certificate numbers" do
      expect(certificate_numbers).to contain_exactly(
        "0000-0000-0000-0000-0001",
        "0000-0000-0000-0000-0003",
        "0000-0000-0000-0000-0005",
        "0000-0000-0000-0000-0011",
      )
    end

    it "returns the NI DEC certificate number as the related certificate number only" do
      expect(related_certificate_numbers).to contain_exactly(
        "0000-0000-0000-0000-0000",
        "0000-0000-0000-0000-0002",
        "0000-0000-0000-0000-0004",
        "0000-0000-0000-0000-0010",
      )
    end
  end
end
