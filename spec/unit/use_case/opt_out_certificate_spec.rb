describe UseCase::OptOutCertificate do
  subject(:use_case) { described_class.new(database_gateway, redis_gateway, certificate_gateway) }

  let(:database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:redis_gateway) do
    instance_double(Gateway::RedisGateway)
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  before do
    allow(database_gateway).to receive(:add_attribute_value).and_return(true)
    allow(redis_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
  end

  context "when marking existing certs as opted out" do
    before do
      allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
      allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: true })
      allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
      use_case.execute
    end

    it "saves 3 opted out certificate " do
      expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
    end
  end

  context "when marking 1 existing certs as opted in" do
    before do
      allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
      allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: false })
      allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
      allow(database_gateway).to receive(:delete_attribute_value)
      use_case.execute
    end

    it "performs a save for each of the 3 certificates " do
      expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
    end

    it "executes the update use case by deleting one record " do
      expect(database_gateway).to have_received(:delete_attribute_value).exactly(1).times
    end
  end
end
