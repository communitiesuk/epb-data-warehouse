describe Gateway::RegisterApiGateway do
  include RSpecUnitMixin

  subject { described_class.new(get_api_client) }

  context "when getting an assessment using the api endpoint" do
    let(:response) { subject.fetch("0000-0000-0000-0000-0666") }

    let!(:sample) do
      Samples.xml("RdSAP-Schema-20.0.0")
    end

    before do
      OauthStub.token
      WebMock
        .stub_request(
          :get,
          "http://test-api.gov.uk/api/assessments/0000-0000-0000-0000-0666",
        )
        .to_return(status: 200, body: sample)
    end

    it "returns the requested certificate from the api" do
      expect(Nokogiri.XML(response)).not_to be_nil
    end
  end

  context "when calling the api to get the meta data for an assessment" do
    let(:meta_data) { subject.fetch_meta_data("0000-0000-0000-0000-0003") }

    let(:sample) do
      {
        "data": {
          "assessmentId": "0000-0000-0000-0000-0003",
          "typeOfAssessment": "RdSAP",
          "optOut": false,
          "createdAt": "2021-08-09T15:30:13.724Z",
          "cancelledAt": nil,
          "notForIssueAt": nil,
          "schemaType": "RdSAP-Schema-20.0.0",
          "addressId": "UPRN-000000000001",
        },
        "meta": {},
      }.to_json
    end

    before do
      OauthStub.token
      WebMock
        .stub_request(
          :get,
          "http://test-api.gov.uk/api/assessments/0000-0000-0000-0000-0003/meta-data",
        )
        .to_return(status: 200, body: sample)
    end

    it "make an http GET to the expected end point" do
      expect { meta_data }.not_to raise_error
    end

    it "checks the rteurned value is in the expected format" do
      expect(meta_data).to match a_hash_including(assessmentId: "0000-0000-0000-0000-0003")
    end
  end
end
