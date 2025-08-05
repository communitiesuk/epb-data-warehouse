describe UseCase::GetRedactedCertificate do
  let(:use_case) { described_class.new(documents_gateway:) }
  let(:documents_gateway) { instance_double Gateway::DocumentsGateway }
  let(:assessment_id) { "0000-0000-0000-0000-0000" }
  let(:response) do
    {
      "some_response" => "a response",
    }
  end

  before do
    allow(documents_gateway).to receive(:fetch_by_id).with(assessment_id:).and_return(response)
  end

  context "when calling the use case" do
    it "calls the gateway to fetch the redacted documents" do
      use_case.execute(assessment_id:)
      expect(documents_gateway).to have_received(:fetch_by_id).with(assessment_id:).exactly(1).times
    end

    it "returns the gateway response" do
      result = use_case.execute(assessment_id:)
      expect(result).to eq(response)
    end
  end

  context "when no document is found" do
    before do
      allow(documents_gateway).to receive(:fetch_by_id).with(assessment_id:).and_return nil
    end

    it "raises a certificate not found errors" do
      expect { use_case.execute(assessment_id:) }.to raise_error(Errors::CertificateNotFound)
    end
  end
end
