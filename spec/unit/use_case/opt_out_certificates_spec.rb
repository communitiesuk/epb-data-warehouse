describe UseCase::OptOutCertificates, set_with_timecop: true do
  subject(:use_case) do
    described_class.new eav_gateway: database_gateway,
                        documents_gateway: documents_gateway,
                        queues_gateway: queues_gateway,
                        certificate_gateway: certificate_gateway,
                        logger: logger
  end

  let(:database_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:documents_gateway) do
    documents_gateway = instance_double(Gateway::DocumentsGateway)
    %i[
      set_top_level_attribute
      delete_top_level_attribute
    ].each { |method| allow(documents_gateway).to receive(method) }
    documents_gateway
  end

  let(:queues_gateway) do
    instance_double(Gateway::QueuesGateway)
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  context "when queues gateway is functioning correctly" do
    before do
      allow(database_gateway).to receive(:add_attribute_value).and_return(true)
      allow(queues_gateway).to receive(:consume_queue).and_return(%w[1235-0000-0000-0000-0000 0000-9999-0000-0000-0001 0000-0000-0000-0000-0002])
    end

    context "when marking existing certs as opted out" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
        use_case.execute
      end

      it "saves 3 opted out certificate to the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
      end

      it "saves 3 opted out certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
        expect(documents_gateway).not_to have_received(:delete_top_level_attribute)
      end
    end

    context "when marking one existing cert as opted in" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data).with("1235-0000-0000-0000-0000").and_return({ optOut: true })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-9999-0000-0000-0001").and_return({ optOut: false })
        allow(certificate_gateway).to receive(:fetch_meta_data).with("0000-0000-0000-0000-0002").and_return({ optOut: true })
        allow(database_gateway).to receive(:delete_attribute_value)
        use_case.execute
      end

      it "performs a save for each of the 3 certificates on the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(3).times
      end

      it "executes the update use case by deleting one attribute value on the EAV store" do
        expect(database_gateway).to have_received(:delete_attribute_value).exactly(1).times
      end

      it "performs a save for each of the 3 certificates on the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times
      end

      it "executes the update use case by deleting one attribute value on the document store" do
        expect(documents_gateway).to have_received(:delete_top_level_attribute).exactly(1).times
      end

      it "uses the expected XXXX-XX-XX XX:XX:XX format for saving the datetime of the opt-out/in" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(3).times.with(include(new_value: Time.now.utc.strftime("%F %T")))
      end
    end

    context "when marking existing certs as opted out but one triggers an error" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data) do |rrn|
          raise StandardError, "could not save for that RRN" if rrn == "1235-0000-0000-0000-0000"

          { optOut: true }
        end
        use_case.execute
      end

      it "saves the two non-erroring opted out certificates to the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end

      it "saves the two non-erroring opted out certificates to the document store" do
        expect(documents_gateway).to have_received(:set_top_level_attribute).exactly(2).times
      end
    end

    context "when marking existing certs as opted out but one has type AC-REPORT" do
      before do
        allow(certificate_gateway).to receive(:fetch_meta_data) do |rrn|
          {
            optOut: true,
            typeOfAssessment: rrn == "1235-0000-0000-0000-0000" ? "AC-REPORT" : "CEPC",
          }
        end
        use_case.execute
      end

      it "saves the two non-AC-REPORT opted out certificates to the EAV store" do
        expect(database_gateway).to have_received(:add_attribute_value).exactly(2).times
      end

      it "saves the two non-AC_REPORT opted out certificates to the document store" do
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
