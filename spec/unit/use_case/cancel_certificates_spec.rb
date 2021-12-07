require "time"

describe UseCase::CancelCertificates do
  subject(:use_case) do
    described_class.new eav_gateway: eav_database_gateway,
                        queues_gateway: queues_gateway,
                        api_gateway: api_gateway,
                        documents_gateway: documents_gateway,
                        logger: logger
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

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  context "when the queues gateway is functioning correctly" do
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

      it "passes the cancelled_at value in expected datetime format (converted from ISO-8601)" do
        use_case.execute
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times.with(include(new_value: "2021-08-13 08:12:51"))
      end
    end

    context "when processing cancellations where there is a certificate without a cancelled_at date" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ cancelledAt: Time.now.utc.xmlschema(3) })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ cancelledAt: nil })
        allow(api_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ cancelledAt: Time.now.utc.xmlschema(3) })
        use_case.execute
      end

      it "skips over the certificate whose cancellation date is null" do
        expect(eav_database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end
    end

    context "when processing cancellations where fetching metadata for one of them fails" do
      before do
        allow(api_gateway).to receive(:fetch_meta_data) do |rrn|
          raise StandardError, "fetching metadata for this RRN failed" if rrn == "1235-0000-0000-0000-0000"

          { cancelledAt: Time.now.utc.iso8601(3) }
        end
        use_case.execute
      end

      it "sends the updates for the other two certificates to the EAV store" do
        expect(eav_database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end

      it "sends the updates for the other two certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(2).times
      end
    end
  end

  context "when the queues gateway is not functioning correctly" do
    before do
      allow(queues_gateway).to receive(:consume_queue).and_raise("bang!")
    end

    it "logs out an error containing the underlying error message" do
      use_case.execute

      expect(logger).to have_received(:error).with(include "bang!")
    end
  end
end
