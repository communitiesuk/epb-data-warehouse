describe Gateway::RegisterApiGateway do
  subject(:gateway) { described_class.new(api_client:) }

  let(:api_client) { Gateway::ApiClient.new }

  context "when getting an assessment using the API endpoint" do
    context "with an assessment that exists on the API" do
      let(:response) { gateway.fetch("0000-0000-0000-0000-0666") }

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

    context "with an assessment that does not exist on the API" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-0000-0000-0667",
          )
          .to_return(status: 404, body: JSON.generate({
            errors: [{
              code: "NOT_FOUND",
              title: "Assessment not found",
            }],
          }))
      end

      it "raises an AssessmentNotFound error" do
        expect { gateway.fetch("0000-0000-0000-0000-0667") }.to raise_error Errors::AssessmentNotFound
      end
    end

    context "with an assessment that is gone from the API" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-0000-0000-0668",
          )
          .to_return(status: 410, body: JSON.generate({
            errors: [{
              code: "GONE",
              title: "Assessment not for issue",
            }],
          }))
      end

      it "raises an AssessmentGone error" do
        expect { gateway.fetch "0000-0000-0000-0000-0668" }.to raise_error Errors::AssessmentGone
      end
    end

    context "with an assessment ID that is badly formed" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-1234",
          )
          .to_return(status: 400, body: JSON.generate({
            errors: [{
              code: "INVALID_REQUEST",
              title: "The requested assessment id is not valid",
            }],
          }))
      end

      it "raises an AssessmentNotFound error" do
        expect { gateway.fetch "0000-0000-1234" }.to raise_error Errors::AssessmentNotFound
      end
    end

    context "when the api is behind a bad gateway" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-1234",
          )
          .to_return(status: 502, body: '<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
</body>
</html>
')
      end

      it "raises a Connection Error" do
        expect { gateway.fetch "0000-0000-1234" }.to raise_error Errors::ConnectionApiError
      end
    end
  end

  context "when calling the api to get the meta data for an assessment" do
    context "with an assessment that exists on the API" do
      let(:meta_data) { gateway.fetch_meta_data("0000-0000-0000-0000-0003") }

      let(:sample) do
        {
          "data": {
            "typeOfAssessment": "RdSAP",
            "optOut": false,
            "createdAt": "2021-08-09T15:30:13.724Z",
            "cancelledAt": nil,
            "notForIssueAt": nil,
            "schemaType": "RdSAP-Schema-20.0.0",
            "assessmentAddressId": "UPRN-000000000001",
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

      it "checks the returned value is in the expected format" do
        expect(meta_data).to match a_hash_including(assessmentAddressId: "UPRN-000000000001")
      end
    end

    context "with an assessment that does not exist on the API" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-0000-0000-0042/meta-data",
          )
          .to_return(status: 404, body: JSON.generate({
            errors: [{
              code: "NOT_FOUND",
              title: "Assessment ID did not return any data",
            }],
          }))
      end

      it "raises an AssessmentNotFound" do
        expect { gateway.fetch_meta_data("0000-0000-0000-0000-0042") }.to raise_error Errors::AssessmentNotFound
      end
    end

    context "when the response is gateway timeout" do
      before do
        OauthStub.token
        WebMock
          .stub_request(
            :get,
            "http://test-api.gov.uk/api/assessments/0000-0000-1234/meta-data",
          )
          .to_return(status: 504, body: '<html>
<head><title>504 Gateway Timeout</title></head>
<body>
<center><h1>504 Gateway Timeout</h1></center>
</body>
</html>
')
      end

      it "raises a Connection Error" do
        expect { gateway.fetch_meta_data "0000-0000-1234" }.to raise_error Errors::ConnectionApiError
      end
    end
  end
end
