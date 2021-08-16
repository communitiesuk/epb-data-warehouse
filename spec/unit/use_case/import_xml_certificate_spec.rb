describe UseCase::ImportXmlCertificate do
  let(:database_gateway) do
    Gateway::AssessmentAttributesGateway.new
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:assessment_id) do
    "0000-0000-0000-0000-0000"
  end

  let(:use_case) do
    described_class.new(database_gateway, certificate_gateway)
  end

  let(:sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  let(:transformed_certificate) do
    allow(certificate_gateway).to receive(:fetch).and_return(sample)
    allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0", assessmentAddressId: "UPRN-000000000000" })
    use_case.execute(assessment_id)
  end

  it "transforms the xml using the view model to_report method " do
    expect(transformed_certificate).to be_a(Hash)
    expect(transformed_certificate[:assessment_id]).to eq("4af9d2c31cf53e72ef6f59d3f59a1bfc500ebc2b1027bc5ca47361435d988e1a")
  end
end
