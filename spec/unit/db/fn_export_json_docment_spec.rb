require_relative "../../shared_context/shared_json_document"

describe "Create psql function to export and redact json data from assessment_documents" do
  include_context "when exporting json data"

  let(:documents_gateway) { Gateway::DocumentsGateway.new }
  let(:assessment_id) { "8570-6826-6530-4969-0202" }

  let(:document) do
    sql = "SELECT fn_export_json_document(document) as document FROM assessment_documents WHERE assessment_id='#{assessment_id}'"
    result = ActiveRecord::Base.connection.exec_query(sql)
    JSON.parse(result.first["document"])
  end
  let(:json_sample) do
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
      "assessment_address_id" => "UPRN-1000000001245",
      "cancelled_at" => "2020-06-01",
      "hashed_assessment_id" => "0000-0000-0000-0000-1111",
      "opt_out" => false,
    }
  end

  let(:cepc_json_sample) do
    json_sample.merge("assessment_type" => "CEPC", "related_rrn" => "0000-0000-0000-0000-0000")
  end

  before do
    documents_gateway.add_assessment(assessment_id:, document: json_sample)
  end

  it "redacts PII from the json document" do
    redacted_keys.each do |key|
      expect(document[key]).to be_nil
    end
  end

  it "adds the uprn based on the value of the assessment_address_id converted into an integer" do
    expect(document["uprn"]).to eq 1_000_000_001_245
  end

  it "removes assessment_address_id key" do
    expect(document["assessment_address_id"]).to be_nil
  end

  context "when the assessment_address_id is an RRN" do
    before do
      json_sample["assessment_address_id"] = "RRN-8570-6826-6530-4969-0202"
      documents_gateway.add_assessment(assessment_id:, document: json_sample)
    end

    it "adds a nil value to uprn" do
      expect(document).to include("uprn" => nil)
    end
  end

  context "when the assessment_type is CEPC" do
    before do
      documents_gateway.add_assessment(assessment_id:, document: cepc_json_sample)
    end

    it "removes related_rrn" do
      expect(document["related_rrn"]).to be_nil
    end

    it "returns related_certificate_number" do
      expect(document["related_certificate_number"]).to eql("0000-0000-0000-0000-0000")
    end
  end
end
