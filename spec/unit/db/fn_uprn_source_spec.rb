require_relative "../../shared_context/shared_json_document"

describe "Create psql function to get URPN source" do
  include_context "when exporting json data"
  let(:assessment_id) { "0000-0000-0000-0000-0000" }
  let(:uprn_source) do
    sql = "SELECT assessment_id, fn_uprn_source((document ->> 'assessment_address_id')::varchar, matched_uprn ) as uprn_source
    FROM assessment_documents WHERE assessment_id='#{assessment_id}'"
    ActiveRecord::Base.connection.exec_query(sql).first["uprn_source"]
  end
  let(:documents_gateway) { Gateway::DocumentsGateway.new }

  let(:matched_uprn) do
    0o00000000000
  end

  before do
    documents_gateway.add_assessment(assessment_id:, document: json_sample)
    Gateway::DocumentsGateway::AssessmentDocument.update(matched_uprn:)
  end

  context "when the assessment_address_id has a UPRN" do
    let(:json_sample) do
      {
        "assessment_address_id" => "UPRN-000000000000",
      }
    end

    it "returns Energy Assessor" do
      expect(uprn_source).to eq "Energy Assessor"
    end
  end

  context "when the assessment_address_id has a UPRN and the matched UPRN is NULL" do
    let(:json_sample) do
      {
        "assessment_address_id" => "UPRN-000000000000",
      }
    end

    let(:matched_uprn) do
      nil
    end

    it "returns Energy Assessor" do
      expect(uprn_source).to eq "Energy Assessor"
    end
  end

  context "when the assessment_address_id has an RRN and a matched UPRN" do
    let(:json_sample) do
      {
        "assessment_address_id" => "RRN-0000-0000-0000-0000-0000",
      }
    end

    it "returns Address Matched" do
      expect(uprn_source).to eq "Address Matched"
    end
  end

  context "when the assessment_address_id has an RRN and no matched UPRN" do
    let(:json_sample) do
      {
        "assessment_address_id" => "RRN-0000-0000-0000-0000-0000",
      }
    end

    let(:matched_uprn) do
      nil
    end

    it "returns no value" do
      expect(uprn_source).to be_nil
    end
  end
end
