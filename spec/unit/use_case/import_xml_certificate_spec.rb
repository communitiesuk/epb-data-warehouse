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
    described_class.new import_certificate_data_use_case: UseCase::ImportCertificateData.new(assessment_attribute_gateway: database_gateway),
                        assessment_attribute_gateway: database_gateway,
                        certificate_gateway: certificate_gateway
  end

  let(:sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  let(:transformed_certificate) do
    allow(certificate_gateway).to receive(:fetch).and_return(sample)
    allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ schemaType: "RdSAP-Schema-20.0.0",
                                                                         assessmentAddressId: "UPRN-000000000000",
                                                                         "typeOfAssessment": "RdSAP",
                                                                         "optOut": false,
                                                                         "createdAt": "2021-07-21T11:26:28.045Z" })
    use_case.execute(assessment_id)
  end

  it "transforms the xml using the view model to_report method " do
    expect(transformed_certificate).to be_a(Hash)
    expect(transformed_certificate["calculation_software_version"]).to eq("13.05r16")
    expect(transformed_certificate["created_at"]).to eq("2021-07-21T11:26:28.045Z")
  end
end
