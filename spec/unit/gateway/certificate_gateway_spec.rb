describe Gateway::CertificateGateway do
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

      expect(Nokogiri.XML response).not_to be_nil
    end


  end
end
