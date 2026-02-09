require_relative "../../shared_context/shared_json_document"

describe "VwExportDocuments" do
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
      "country_code" => "EAW",
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
      "assessment_address_id" => "UPRN-0000000001245",
    }
  end

  context "when fetching from vw_export_documents_2020" do
    before do
      documents_gateway.add_assessment(assessment_id:, document: assessment_data_to_redact)
      assessment_search_gateway.insert_assessment(assessment_id:, document: assessment_data_to_redact, country_id: 1)
    end

    let(:redacted_row) do
      sql = "SELECT * FROM vw_export_documents_2020 WHERE certificate_number='#{assessment_id}'"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result.first
    end

    let(:redacted_document) do
      redacted_row["document"]
    end

    it "redacts PII from the json document" do
      redacted_keys.each do |key|
        expect(redacted_document[key]).to be_nil
      end
    end

    it "contains the assessment_type column" do
      expect(redacted_row["assessment_type"]).to eq "RdSAP"
    end

    it "updates the uprn value" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq 1245
    end

    it "contains the year column" do
      expect(redacted_row["year"]).to eq 2020
    end
  end

  context "when generating redacted documents tables" do
    let(:redacted_table_names) do
      sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'vw_export_documents_%';"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result
    end

    it "generates the correct number of tables" do
      expect(redacted_table_names.length).to eq 15
    end
  end

  context "when checking that vw_export_documents exist in DB from 2012 until current year" do
    let(:current_year) { Time.now.year }

    let(:view_names) do
      sql = "SELECT table_name
                 FROM  information_schema.views
                 WHERE  table_schema NOT IN ('information_schema', 'pg_catalog')
                 AND table_name LIKE 'vw_export_documents_%'"
      ActiveRecord::Base.connection.exec_query(sql).rows.flatten
    end

    it "includes vw_export_documents views for every year from 2012 to current year" do
      expected = (2012..current_year).map { |year| "vw_export_documents_#{year}" }
      missing = expected - view_names

      expect(missing).to eq([])
    end
  end
end
