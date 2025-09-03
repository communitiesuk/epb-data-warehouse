describe "VwDomesticDocuments" do
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
      "uprn" => "UPRN-0000000001245",
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
      "assessment_address_id" => "UPRN-0000000001245",
    }
  end

  context "when fetching from vw_domestic_documents_2020" do
    before do
      documents_gateway.add_assessment(assessment_id:, document: assessment_data_to_redact)
      assessment_search_gateway.insert_assessment(assessment_id:, document: assessment_data_to_redact, country_id: 1)
    end

    let(:redacted_row) do
      sql = "SELECT * FROM vw_domestic_documents_2020 WHERE certificate_number='#{assessment_id}'"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result.first
    end

    let(:redacted_document) do
      redacted_row["document"]
    end

    it "redacts PII from the json document" do
      expect(redacted_document["scheme_assessor_id"]).to be_nil
      expect(redacted_document["equipment_operator"]).to be_nil
      expect(redacted_document["equipment_owner"]).to be_nil
      expect(redacted_document["owner"]).to be_nil
      expect(redacted_document["occupier"]).to be_nil
    end

    it "contains the assessment_type column" do
      expect(redacted_row["assessment_type"]).to eq "RdSAP"
    end

    it "contains the year column" do
      expect(redacted_row["year"]).to eq 2020
    end
  end

  context "when generating redacted documents tables" do
    let(:redacted_table_names) do
      sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'vw_domestic_documents_%';"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result
    end

    it "generates the correct number of tables" do
      expect(redacted_table_names.length).to eq 14
    end
  end
end
