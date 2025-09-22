require_relative "../../shared_context/shared_json_document"

describe "VwJsonDocumentsYesterday" do
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
      "country_code" => "EAW",
      "uprn" => "UPRN-0000000001245",
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
      "assessment_address_id" => "UPRN-0000000001245",
    }
  end

  let(:result) do
    sql = "SELECT * FROM vw_json_documents_yesterday"
    ActiveRecord::Base.connection.exec_query(sql)
  end

  before do
    documents_gateway.add_assessment(assessment_id:, document: assessment_data_sample)
    assessment_search_gateway.insert_assessment(assessment_id:, document: assessment_data_sample, country_id: 1)
  end

  context "when fetching from vw_json_documents_yesterday without data" do
    it "returns no results" do
      expect(result.length).to eq(0)
    end
  end

  context "when fetching from vw_json_documents_yesterday with some data" do
    before do
      Timecop.freeze(Date.yesterday.to_time.change(hour: 12, min: 30))
      assessment_id_yesterday = "0000-0000-0000-0000-0002"
      assessment_data_sample_from_yesterday = assessment_data_sample.merge({ "rrn" => assessment_id_yesterday })
      documents_gateway.add_assessment(assessment_id: assessment_id_yesterday, document: assessment_data_sample_from_yesterday)
      assessment_search_gateway.insert_assessment(assessment_id: assessment_id_yesterday, document: assessment_data_sample_from_yesterday, country_id: 1)
      Timecop.return
    end

    let(:redacted_document) do
      result.first["document"]
    end

    it "returns the expected certificate" do
      expect(result.first["certificate_number"]).to eq("0000-0000-0000-0000-0002")
    end

    it "redacts PII from the json document" do
      redacted_keys.each do |key|
        expect(redacted_document[key]).to be_nil
      end
    end

    it "contains the assessment_type column" do
      expect(result.first["assessment_type"]).to eq "RdSAP"
    end

    it "updates the uprn value" do
      expect(JSON.parse(redacted_document)["uprn"]).to eq 1245
    end

    it "contains the year column" do
      expect(result.first["year"]).to eq 2020
    end
  end
end
