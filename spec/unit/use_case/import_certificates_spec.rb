describe UseCase::ImportCertificates do
  subject(:use_case) do
    described_class.new import_xml_certificate_use_case: import_xml_certificate_use_case,
                        queues_gateway: queues_gateway
  end

  let(:import_xml_certificate_use_case) do
    instance_double(UseCase::ImportXmlCertificate)
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let!(:sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  let(:schema_type) { "TODO" }

  before do
    allow(Gateway::QueuesGateway).to receive(:new).and_return(queues_gateway)
    allow(queues_gateway).to receive(:consume_queue).and_return(%w[
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
