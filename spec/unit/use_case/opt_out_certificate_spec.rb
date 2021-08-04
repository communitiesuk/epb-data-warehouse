describe UseCase::OptOutCertificate do
  context "Update certificate to be opted out" do
    subject { described_class.new(database_gateway) }

    let(:database_gateway) do
      instance_double("Gateway::AssessmentAttributesGateway")
    end

    it "loads the use case" do
      expect { subject }.not_to raise_error
    end

    it "updates the certificate and returns true" do
      allow(database_gateway).to receive(:update_assessment_attribute).and_return(true)
      expect(subject.execute("0000-0000-0000-0000-0000")).to eq(true)
    end
  end
end
