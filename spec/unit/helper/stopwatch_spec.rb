describe Helper::Stopwatch do
  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:info)
    logger
  end

  context "when passing a block into a call to log elapsed time" do
    let(:block_int) { instance_double(Integer) }

    let(:message) { "casting an integer to a string" }

    before do
      allow(block_int).to receive(:to_s)
      described_class.log_elapsed_time logger, message do
        block_int.to_s
      end
    end

    it "executes the block" do
      expect(block_int).to have_received(:to_s)
    end

    it "logs out with a message contained" do
      expect(logger).to have_received(:info).with(include message)
    end
  end

  context "when using the return value of a block being logged" do
    it "returns the return of the block" do
      expected_return = "i am the return"
      expect(described_class.log_elapsed_time(logger, "message") { expected_return }).to eq expected_return
    end
  end
end
