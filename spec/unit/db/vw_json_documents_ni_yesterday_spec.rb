require_relative "../../shared_context/shared_json_document"

describe "VwJsonDocumentsNiYesterday" do
  include_context "when exporting json data"

  let(:documents_gateway) { Gateway::DocumentsGateway.new }
  let(:assessment_search_gateway) { Gateway::AssessmentSearchGateway.new }
  let(:assessment_id) { "8570-6826-6530-4969-0202" }

  let(:assessment_data_sample) do
    {
      "schema_version_original" => "LIG-19.0",
      "sap_version" => 9.94,
      "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
      "calculation_software_version" => "4.05r0005",
      "inspection_date" => "2020-06-01",
      "report_type" => 2,
      "completion_date" => "2020-06-01",
      "registration_date" => "2020-06-01",
      "status" => "entered",
      "language_code" => 1,
      "tenure" => 1,
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "region_code" => 17,
      "country_code" => "NIR",
      "uprn" => "UPRN-0000000001245",
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
      "assessment_address_id" => "UPRN-0000000001245",
    }
  end

  let(:result) do
    sql = <<~SQL
      SELECT *
      FROM vw_json_documents_ni_yesterday
      WHERE certificate_number = '#{assessment_id}'
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  let(:redacted_document) do
    result.first["document"]
  end

  context "when there are no NI assessments from yesterday" do
    it "returns no results" do
      expect(result).to be_empty
    end
  end

  context "when there is an NI assessment from yesterday" do
    before do
      Timecop.freeze(Date.yesterday.to_time.change(hour: 12, min: 30)) do
        documents_gateway.add_assessment(
          assessment_id:,
          document: assessment_data_sample,
        )

        assessment_search_gateway.insert_assessment(
          assessment_id:,
          document: assessment_data_sample,
          country_id: 3,
        )
      end
    end

    it "returns the expected certificate" do
      expect(result.first["certificate_number"]).to eq(assessment_id)
    end

    it "redacts PII from the JSON document" do
      redacted_keys.each do |key|
        expect(redacted_document[key]).to be_nil
      end
    end

    it "contains the assessment_type column" do
      expect(result.first["assessment_type"]).to eq("RdSAP")
    end

    it "updates the uprn value" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq(1245)
    end

    it "contains the year column" do
      expect(result.first["year"]).to eq(2020)
    end
  end

  context "when there is a non-NI assessment from yesterday" do
    let(:non_ni_assessment_id) { "8570-6826-6530-4969-0204" }

    let(:non_ni_result) do
      sql = <<~SQL
        SELECT *
        FROM vw_json_documents_ni_yesterday
        WHERE certificate_number = '#{non_ni_assessment_id}'
      SQL

      ActiveRecord::Base.connection.exec_query(sql)
    end

    let(:non_ni_assessment_document) do
      assessment_data_sample.merge("country_code" => "EAW")
    end

    before do
      Timecop.freeze(Date.yesterday.to_time.change(hour: 12, min: 30)) do
        documents_gateway.add_assessment(
          assessment_id: non_ni_assessment_id,
          document: non_ni_assessment_document,
        )

        assessment_search_gateway.insert_assessment(
          assessment_id: non_ni_assessment_id,
          document: non_ni_assessment_document,
          country_id: 1,
        )
      end
    end

    it "does not include the assessment" do
      expect(non_ni_result).to be_empty
    end
  end

  context "when fetching an NI assessment with address matching data" do
    let(:assessment_id_yesterday) { "0000-0000-0000-0000-0002" }

    let(:result) do
      sql = <<~SQL
        SELECT *
        FROM vw_json_documents_ni_yesterday
        WHERE certificate_number = '#{assessment_id_yesterday}'
      SQL

      ActiveRecord::Base.connection.exec_query(sql)
    end

    before do
      Timecop.freeze(Date.yesterday.to_time.change(hour: 12, min: 30)) do
        assessment_data_sample_from_yesterday = assessment_data_sample.merge(
          "rrn" => assessment_id_yesterday,
          "assessment_address_id" => "RRN-#{assessment_id_yesterday}",
        )

        documents_gateway.add_assessment(
          assessment_id: assessment_id_yesterday,
          document: assessment_data_sample_from_yesterday,
        )

        documents_gateway.update_matched_uprn(
          assessment_id: assessment_id_yesterday,
          matched_uprn: "200000000001",
        )

        assessment_search_gateway.insert_assessment(
          assessment_id: assessment_id_yesterday,
          document: assessment_data_sample_from_yesterday,
          country_id: 3,
        )
      end
    end

    after do
      documents_gateway.update_matched_uprn(
        assessment_id: assessment_id_yesterday,
        matched_uprn: nil,
      )
    end

    it "updates the uprn value" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq("200000000001".to_i)
    end

    it "updates the uprn_source value" do
      expect(JSON.parse(redacted_document)["uprn_source"]).to eq("Address Matched")
    end
  end

  context "when fetching an NI assessment without a valid matched uprn" do
    let(:assessment_id_yesterday) { "0000-0000-0000-0000-0003" }

    let(:result) do
      sql = <<~SQL
        SELECT *
        FROM vw_json_documents_ni_yesterday
        WHERE certificate_number = '#{assessment_id_yesterday}'
      SQL

      ActiveRecord::Base.connection.exec_query(sql)
    end

    before do
      Timecop.freeze(Date.yesterday.to_time.change(hour: 12, min: 30)) do
        assessment_data_sample_from_yesterday = assessment_data_sample.merge(
          "rrn" => assessment_id_yesterday,
          "assessment_address_id" => "RRN-#{assessment_id_yesterday}",
        )

        documents_gateway.add_assessment(
          assessment_id: assessment_id_yesterday,
          document: assessment_data_sample_from_yesterday,
        )

        assessment_search_gateway.insert_assessment(
          assessment_id: assessment_id_yesterday,
          document: assessment_data_sample_from_yesterday,
          country_id: 3,
        )
      end
    end

    it "updates the uprn value to nil" do
      expect(JSON.parse(redacted_document)["uprn"]).to be_nil
    end

    it "updates the uprn_source value to an empty string" do
      expect(JSON.parse(redacted_document)["uprn_source"]).to eq("")
    end
  end
end
