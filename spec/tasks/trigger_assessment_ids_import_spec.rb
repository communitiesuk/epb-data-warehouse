describe "add assessment IDs to assessment queue rake" do
  subject(:rake) { get_task("trigger_assessment_ids_import") }

  let(:data) { "1234-5678-1234-2278-1234,0000-0000-0000-0000-0000" }
  let(:redis) { MockRedis.new }
  let(:gateway) { instance_double Gateway::QueuesGateway }

  before do
    allow($stdout).to receive(:puts)
    allow(gateway).to receive(:push_to_queue)
    allow(Container).to receive(:queues_gateway).and_return gateway
  end

  context "when calling the rake" do
    it "does not raise an error" do
      expect { rake.invoke(data) }.not_to raise_error
    end

    it "passes the array of assessment_ids the gateway" do
      rake.invoke(data)
      expect(gateway).to have_received(:push_to_queue).with(:assessments, data.split(","), jump_queue: true).exactly(1).times
    end

    it "outputs the number of assessment ids added to the queue" do
      expect { rake.invoke(data) }.to output(/pushed 2 assessment_ids to queue!/).to_stdout
    end

    it "removes all white space" do
      data_with_gaps = " 1234-5678-1234-2278-1234, 0000-0000-0000-0000-0000"
      rake.invoke(data_with_gaps)
      expect(gateway).to have_received(:push_to_queue).with(:assessments, data.split(","), jump_queue: true).exactly(1).times
    end
  end

  context "when invoking the rake without arguments" do
    it "raise and argument error" do
      expect { rake.invoke }.to raise_error(Boundary::ArgumentMissing)
    end
  end
end
