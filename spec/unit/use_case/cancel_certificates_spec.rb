describe UseCase::CancelCertificates do
  subject(:use_case) do
    described_class.new eav_gateway: eav_database_gateway,
                        queues_gateway: queues_gateway,
                        api_gateway: api_gateway,
                        documents_gateway: documents_gateway
  end

  let(:eav_database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    allow(documents_gateway).to receive(:set_top_level_attribute)
    documents_gateway
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let(:api_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  before do
    allow(eav_database_gateway).to receive(:add_attribute_value).and_return(true)
    allow(queues_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
  end

  context "when processing cancellations where there is a cancelled_at attribute present" do
    before do
      allow(api_gateway).to receive(:fetch_meta_data).and_return({ cancelledAt: "2021-08-13T08:12:51.205Z" })
    end

    it "saves the relevant certificates to database" do
      expect { use_case.execute }.not_to raise_error
      expect(eav_database_gateway).to have_received(:add_attribute_value).exactly(3).times
    end

    it "passes the relevant certificates to the documents gateway" do
      use_case.execute
      expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
    end
  end

  context "when processing cancellations where there is a certificate without a cancelled_at date" do
    before do
      allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc })
      allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil })
      allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc })
      use_case.execute
    end

    it "skips over the certificate whose cancellation date is null" do
      expect(eav_database_gateway).to have_received(:add_attribute_value).exactly(2).times
    end
  end
end
