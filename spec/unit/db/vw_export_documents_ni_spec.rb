require_relative "../../shared_context/shared_json_document"

describe "VwExportDocumentsNi" do
  include_context "when exporting json data"

  let(:documents_gateway) { Gateway::DocumentsGateway.new }
  let(:assessment_search_gateway) { Gateway::AssessmentSearchGateway.new }

  let(:assessment_id) { "8570-6826-6530-4969-0202" }

  let(:assessment_data_to_redact) do
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
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
      "assessment_address_id" => "UPRN-0000000001245",
    }
  end

  let(:assessment_data_with_invalid_address_id) do
    assessment_data_to_redact.merge(
      "assessment_address_id" => "RRN-0000-0000-0000-0000-1245",
    )
  end

  let(:redacted_row) do
    sql = <<~SQL
      SELECT *
      FROM vw_export_documents_ni
      WHERE certificate_number = '#{assessment_id}'
    SQL

    ActiveRecord::Base.connection.exec_query(sql).first
  end

  let(:redacted_document) do
    redacted_row["document"]
  end

  context "when fetching an NI assessment" do
    before do
      documents_gateway.add_assessment(
        assessment_id:,
        document: assessment_data_to_redact,
      )

      assessment_search_gateway.insert_assessment(
        assessment_id:,
        document: assessment_data_to_redact,
        country_id: 3,
      )
    end

    it "redacts PII from the JSON document" do
      redacted_keys.each do |key|
        expect(redacted_document[key]).to be_nil
      end
    end

    it "contains the assessment_type column" do
      expect(redacted_row["assessment_type"]).to eq("RdSAP")
    end

    it "updates the uprn value" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq(1245)
    end

    it "updates the uprn_source value" do
      expect(JSON.parse(redacted_document)["uprn_source"]).to eq("Energy Assessor")
    end

    it "contains the year column" do
      expect(redacted_row["year"]).to eq(2020)
    end
  end

  context "when including matched_uprn and the assessment_address_id starts with RRN" do
    before do
      documents_gateway.add_assessment(
        assessment_id:,
        document: assessment_data_with_invalid_address_id,
      )

      documents_gateway.update_matched_uprn(
        assessment_id:,
        matched_uprn: "123400000055",
      )

      assessment_search_gateway.insert_assessment(
        assessment_id:,
        document: assessment_data_with_invalid_address_id,
        country_id: 3,
      )
    end

    after do
      documents_gateway.update_matched_uprn(
        assessment_id:,
        matched_uprn: nil,
      )
    end

    it "updates the uprn value with the matched uprn" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq("123400000055".to_i)
    end

    it "updates the uprn_source value with Address Matched" do
      expect(JSON.parse(redacted_document)["uprn_source"]).to eq("Address Matched")
    end
  end

  context "when there is no matched_uprn and the assessment_address_id starts with RRN" do
    before do
      documents_gateway.add_assessment(
        assessment_id:,
        document: assessment_data_with_invalid_address_id,
      )

      assessment_search_gateway.insert_assessment(
        assessment_id:,
        document: assessment_data_with_invalid_address_id,
        country_id: 3,
      )
    end

    it "updates the uprn value to nil" do
      expect(JSON.parse(redacted_document)["uprn"]).to be_nil
    end

    it "updates the uprn_source to an empty string" do
      expect(JSON.parse(redacted_document)["uprn_source"]).to eq("")
    end
  end

  context "when the assessment is not from Northern Ireland" do
    let(:non_ni_assessment_id) { "8570-6826-6530-4969-0203" }

    let(:non_ni_assessment_document) do
      assessment_data_to_redact.merge("country_code" => "EAW")
    end

    before do
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

    it "does not include the assessment in the NI export view" do
      sql = <<~SQL
        SELECT *
        FROM vw_export_documents_ni
        WHERE certificate_number = '#{non_ni_assessment_id}'
      SQL

      result = ActiveRecord::Base.connection.exec_query(sql)

      expect(result.rows).to be_empty
    end
  end

  it "exists as a database view" do
    sql = <<~SQL
      SELECT table_name
      FROM information_schema.views
      WHERE table_schema = 'public'
        AND table_name = 'vw_export_documents_ni'
    SQL

    result = ActiveRecord::Base.connection.exec_query(sql)

    expect(result.rows).to contain_exactly(%w[vw_export_documents_ni])
  end
end
