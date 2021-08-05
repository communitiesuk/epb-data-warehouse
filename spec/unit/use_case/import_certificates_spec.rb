describe UseCase::ImportCertificates do
  let(:database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end
  let(:import_xml_certificate_use_case) do
    instance_double(UseCase::ImportXmlCertificate)
  end

  let(:certificate_gateway) do
    instance_double(Gateway::CertificateGateway)
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

    allow(Gateway::CertificateGateway).to receive(:new).and_return(certificate_gateway)
    allow(certificate_gateway).to receive(:fetch).and_return(sample)

    allow(Gateway::RedisGateway).to receive(:new).and_return(redis_gateway)
    allow(redis_gateway).to receive(:fetch_queue).and_return(%w[
      0000-0000-0000-0000-0000
      0000-0000-0000-0000-0001
      0000-0000-0000-0000-0002
    ])
    allow(redis_gateway).to receive(:remove_from_queue)
    allow(UseCase::ImportXmlCertificate).to receive(:new).and_return(import_xml_certificate_use_case)
    allow(import_xml_certificate_use_case).to receive(:execute)
  end

  it "calls the import XML certificate use case" do
    expect { use_case.execute }.not_to raise_error

    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0000", schema_type)
    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0001", schema_type)
    expect(import_xml_certificate_use_case).to have_received(:execute).with("0000-0000-0000-0000-0002", schema_type)
  end

  it "calls the method to removes the assessment id from the redis queue" do
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0000", schema_type)
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0001", schema_type)
    allow(import_xml_certificate_use_case).to receive(:execute).with("0000-0000-0000-0000-0002", schema_type)

    expect { use_case.execute }.not_to raise_error

    expect(redis_gateway).to have_received(:remove_from_queue).exactly(3).times
  end
end
