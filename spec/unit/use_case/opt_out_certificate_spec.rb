describe UseCase::OptOutCertificate do
  subject(:use_case) { described_class.new(database_gateway, redis_gateway, certificate_gateway) }

  let(:database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:redis_gateway) do
    instance_double(Gateway::RedisGateway)
  end

  let(:certificate_gateway) do
    instance_double(Gateway::CertificateGateway)
  end

  before do
    allow(database_gateway).to receive(:add_attribute_value).and_return(true)
    allow(redis_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
  end

  context "when marking existing certs as opted out" do
    before do
      allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ optOut: true })
    end

    it "executes the update use case without error" do
      expect { use_case.execute }.not_to raise_error
    end
  end

  context "when marking existing certs as opted in" do
    before do
      allow(certificate_gateway).to receive(:fetch_meta_data).and_return({ optOut: false })
      allow(database_gateway).to receive(:delete_attribute_value)
    end

    it "executes the update use case by deleting a record without error" do
      expect { use_case.execute }.not_to raise_error
    end
  end
end
