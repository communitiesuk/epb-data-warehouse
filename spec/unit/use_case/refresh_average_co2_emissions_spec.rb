describe UseCase::RefreshAverageCo2Emissions do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::AverageCo2EmissionsGateway)
  end

  before do
    allow(gateway).to receive(:refresh)
  end

  describe "#execute" do
    it "calls the refresh gateway method without error" do
      expect { use_case.execute }.not_to raise_error
      expect(gateway).to have_received(:refresh).exactly(:once)
    end

    context "when calling the use case with the concurrently flag" do
      it "passes argument on to the gateway" do
        use_case.execute(concurrently: true)
        expect(gateway).to have_received(:refresh).with(concurrently: true).exactly(:once)
      end
    end
  end
end
