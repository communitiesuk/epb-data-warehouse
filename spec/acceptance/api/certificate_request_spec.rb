require_relative "../../shared_context/shared_lodgement"

describe "DomesticSearchController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  before do
    document = { assessment_type: "SAP", postcode: "SW10 1AA" }
    add_assessment(assessment_id:, schema_type: "SAP-Schema-19.1.0", type_of_assessment: "SAP")
    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id:, document:, country_id: 1)
  end

  context "when the response is successful" do
    let(:response) do
      header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
      get "/api/certificate?certificate_number=0000-0000-0000-0000-0000"
    end

    it "returns a redacted json document as a hash" do
      response_body = JSON.parse(response.body)
      expect(response_body["data"]).not_to be_nil
    end

    it "returns a 200 status code" do
      expect(response.status).to eq(200)
    end

    it "returns valid json data" do
      response_body = JSON.parse(response.body)
      expect { JSON.parse(response_body["data"]) }.not_to raise_error
    end
  end

  context "when the certificate request is invalid" do
    let(:response) do
      header("Authorization", "Bearer #{get_valid_jwt(%w[epb-data-front:read])}")
      get "/api/certificate?certificate_number=0000-0000-0000-0000-0001"
    end

    it "returns a 404 when the assessment is not found" do
      expect(response.status).to eq(404)
    end

    it "raises an error for the missing assessment" do
      response_body = JSON.parse(response.body)
      expect(response_body["data"]["error"]).to include "Certificate not found"
    end
  end
end
