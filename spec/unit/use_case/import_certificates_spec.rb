describe UseCase::ImportCertificates do
  let(:database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end
  let(:import_xml_certificate_use_case) do
    instance_double(UseCase::ImportXmlCertificate)
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:redis_gateway) do
    instance_double(Gateway::RedisGateway)
  end

  let!(:use_case) do
    described_class.new(database_gateway, certificate_gateway, redis_gateway)
  end

  let!(:sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  let(:schema_type) { "TODO" }

  before do
    allow(Gateway::AssessmentAttributesGateway).to receive(:new).and_return(database_gateway)
    allow(database_gateway).to receive(:add_attribute_value).and_return(1)

    allow(Gateway::RegisterApiGateway).to receive(:new).and_return(certificate_gateway)
    allow(certificate_gateway).to receive(:fetch).and_return(sample)

    allow(Gateway::RedisGateway).to receive(:new).and_return(redis_gateway)
    allow(redis_gateway).to receive(:consume_queue).and_return(%w[
      0000-0000-0000-0000-0000
      0000-0000-0000-0000-0001
      0000-0000-0000-0000-0002
    ])
    allow(UseCase::ImportXmlCertificate).to receive(:new).and_return(import_xml_certificate_use_case)
    allow(import_xml_certificate_use_case).to receive(:execute)
  end

  it "calls the import XML certificate use case" do
    expect { use_case.execute }.not_to raise_error

    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0000")
    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0001")
    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0002")
  end

  it "calls the method to removes the assessment id from the redis queue" do
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0000")
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0001")
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0002")

    expect { use_case.execute }.not_to raise_error
  end
end
