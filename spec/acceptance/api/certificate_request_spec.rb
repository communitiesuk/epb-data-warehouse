require_relative "../../shared_context/shared_lodgement"

describe "DomesticSearchController" do
  include RSpecDataWarehouseApiServiceMixin
  include_context "when lodging XML"

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:authenticate_user_use_case) do
    instance_double(UseCase::AuthenticateUser)
  end

  before do
    document = { assessment_type: "SAP", postcode: "SW10 1AA", registration_date: Time.now, assessment_address_id: "UPRN-0000000001245" }
    add_assessment(assessment_id:, schema_type: "SAP-Schema-19.1.0", type_of_assessment: "SAP")
    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id:, document:, country_id: 1)
    allow(Container).to receive(:authenticate_user_use_case).and_return(authenticate_user_use_case)
    allow(authenticate_user_use_case).to receive(:execute).and_return(true)
    header("Authorization", "Bearer valid-bearer-token")
  end

  context "when the response is successful" do
    let(:response) do
      get "/api/certificate?certificate_number=0000-0000-0000-0000-0000"
    end

    it "returns a redacted json document as a hash" do
      response_body = JSON.parse(response.body)
      expect(response_body["data"]).to be_a(Hash)
    end

    it "returns a 200 status code" do
      expect(response.status).to eq(200)
    end
  end

  context "when the certificate request is invalid" do
    let(:response) do
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
