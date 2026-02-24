require_relative "../../shared_context/shared_json_document"

describe "Create psql function to export and redact json data from assessment_documents" do
  include_context "when exporting json data"

  let(:documents_gateway) { Gateway::DocumentsGateway.new }
  let(:assessment_id) { "8570-6826-6530-4969-0202" }

  let(:document) do
    sql = "SELECT fn_export_json_document(document, matched_uprn) as document FROM assessment_documents WHERE assessment_id='#{assessment_id}'"
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
      "energy_rating_current" => 75,
      "energy_rating_potential" => 75,
    }
  end

  let(:cepc_json_sample) do
    sample = json_sample.merge("assessment_type" => "CEPC", "related_rrn" => "0000-0000-0000-0000-0000", "asset_rating" => 25)
    sample.delete("energy_rating_current")
    sample
  end

  before do
    documents_gateway.add_assessment(assessment_id:, document: json_sample)
  end

  it "redacts PII from the json document" do
    redacted_keys.each do |key|
      expect(document[key]).to be_nil
    end
  end

  it "adds the potential_energy_efficiency_band key based on the energy_rating_potential" do
    expect(document["potential_energy_efficiency_band"]).to eq "C"
  end

  it "produces" do
    expect(document["uprn"]).to eq 1_000_000_001_245
  end

  it "removes assessment_address_id key" do
    expect(document["assessment_address_id"]).to be_nil
  end

  it "has a current_energy_efficiency_band of C" do
    expect(document["current_energy_efficiency_band"]).to eq "C"
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

    it "has a current_energy_efficiency_band of A" do
      expect(document["current_energy_efficiency_band"]).to eq "A"
    end
  end

  context "when the assessment_type is DEC" do
    before do
      documents_gateway.add_assessment(assessment_id:, document: dec_sample)
    end

    let(:dec_sample) do
      sample = json_sample.merge("assessment_type" => "DEC", "related_rrn" => "0000-0000-0000-0000-0000", "this_assessment" => { "energy_rating" => 38 })
      sample.delete("energy_rating_current")
      sample
    end

    it "has a current_energy_efficiency_band of B" do
      expect(document["current_energy_efficiency_band"]).to eq "B"
    end
  end

  context "when the assessment_type is DEC-RR" do
    before do
      documents_gateway.add_assessment(assessment_id:, document: dec_rr_sample)
    end

    let(:dec_rr_sample) do
      sample = json_sample.merge("assessment_type" => "DEC-RR", "related_rrn" => "0000-0000-0000-0000-0000")
      sample.delete("energy_rating_current")
      sample
    end

    it "has no energy band" do
      expect(document["current_energy_efficiency_band"]).to be_nil
    end
  end

  context "when there's a matched UPRN and a valid address_id" do
    let(:valid_address_id_sample) do
      sample = json_sample.clone
      sample
    end

    before do
      documents_gateway.add_assessment(assessment_id:, document: valid_address_id_sample)
      documents_gateway.update_matched_uprn(assessment_id:, matched_uprn: nil)
    end

    it "returns Energy Assessor on uprn_source" do
      expect(document["uprn_source"]).to eq("Energy Assessor")
    end

    it "returns uprn nil" do
      expect(document["uprn"]).to eq("1000000001245".to_i)
    end
  end

  context "when there's a matched UPRN and the address_id is an RRN" do
    let(:invalid_address_id_sample) do
      sample = json_sample.merge("assessment_address_id" => "RRN-0000-0000-0000-0000-0000")
      sample
    end

    before do
      documents_gateway.add_assessment(assessment_id:, document: invalid_address_id_sample)
      documents_gateway.update_matched_uprn(assessment_id:, matched_uprn: "10000003".to_i)
    end

    after do
      documents_gateway.update_matched_uprn(assessment_id:, matched_uprn: nil)
    end

    it "returns Address Matched on uprn_source" do
      expect(document["uprn_source"]).to eq("Address Matched")
    end

    it "returns address matched uprn" do
      expect(document["uprn"]).to eq("10000003".to_i)
    end
  end

  context "when there's no matched UPRN and the address_id is an RRN" do
    let(:invalid_address_id_sample) do
      sample = json_sample.merge("assessment_address_id" => "RRN-0000-0000-0000-0000-0000")
      sample
    end

    before do
      documents_gateway.add_assessment(assessment_id:, document: invalid_address_id_sample)
    end

    it "returns nothing on uprn_source" do
      expect(document["uprn_source"]).to eq("")
    end

    it "returns uprn nil" do
      expect(document["uprn"]).to be_nil
    end
  end

  context "when there's an RRN address_id and no matched URPN" do
    let(:valid_address_id_sample) do
      sample = json_sample.clone
      sample["assessment_address_id"] = "RRN-0000-0000-0000-0000-1111"
      sample
    end

    before do
      documents_gateway.add_assessment(assessment_id:, document: valid_address_id_sample)
      documents_gateway.update_matched_uprn(assessment_id:, matched_uprn: nil)
    end

    it "returns Energy Assessor on uprn_source" do
      expect(document["uprn_source"]).to eq("")
    end

    it "returns uprn nil" do
      expect(document["uprn"]).to be_nil
    end
  end
end
