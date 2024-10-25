describe UseCase::RefreshMaterializedView do
  subject(:use_case) do
    described_class.new(gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::MaterializedViewsGateway)
  end

  before do
    allow(gateway).to receive(:refresh)
  end

  describe "#execute" do
    it "calls the refresh gateway method without error" do
      expect { use_case.execute(name: "mvw_name") }.not_to raise_error
      expect(gateway).to have_received(:refresh).with(name: "mvw_name", concurrently: false).exactly(:once)
    end

    context "when the view name is not found" do
      it "raises an error" do
        allow(gateway).to receive(:refresh).and_raise Boundary::InvalidArgument.new("wrong_view")
        expect { use_case.execute(name: "wrong_view") }.to raise_error(Boundary::InvalidArgument, /wrong_view/)
      end
    end

    context "when calling the use case with the concurrently flag" do
      it "passes argument on to the gateway" do
        use_case.execute(name: "mvw_name", concurrently: true)
        expect(gateway).to have_received(:refresh).with(name: "mvw_name", concurrently: true).exactly(:once)
      end
    end
  end
end
