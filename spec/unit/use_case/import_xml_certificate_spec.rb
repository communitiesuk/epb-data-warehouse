describe UseCase::ImportXmlCertificate do
  context "call the use case import an xml document in the database" do
    let(:gateway) do
      instance_double(Gateway::AssessmentAttributesGateway)
    end

    let!(:use_case) do
      UseCase::ImportXmlCertificate.newgateway
    end

    let!(:sample) do
      Samples.xml("RdSAP-Schema-20.0.0")
    end

    before do
      allow(gateway).to receive(:add_attribute).and_return("")
      allow(gateway).to receive(:add_attribute_value).and_return("")
    end

    it "transforms the xml using the view model to report method " do
      expect(use_case.execute(sample, "RdSAP-Schema-20.0.0")).to be_a(Hash)
    end
  end
end
