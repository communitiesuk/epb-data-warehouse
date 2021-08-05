describe UseCase::OptOutCertificate do
  subject(:use_case) { described_class.new(database_gateway) }

  let(:database_gateway) do
    instance_double("Gateway::AssessmentAttributesGateway")
  end

  it "loads the use case" do
    expect { use_case }.not_to raise_error
  end

  it "updates the certificate and returns true" do
    allow(database_gateway).to receive(:update_assessment_attribute).and_return(true)
    expect(use_case.execute("0000-0000-0000-0000-0000")).to eq(true)
  end
end
