describe "Export SAP heat pump  EPC count rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("redis_export:save_heat_pump_sap_count") }

    let(:use_case) { instance_double(UseCase::SaveHeatPumpSapCount) }

    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:write)
      allow(Container).to receive(:save_heat_pump_sap_count_use_case).and_return(use_case)
      allow(use_case).to receive(:execute)
    end

    after do
      Container.reset!
    end

    it "run the tasks without error" do
      expect { task.invoke }.not_to raise_error
    end

    it "gets the correct use case from factory" do
      task.invoke
      expect(use_case).to have_received(:execute)
    end

    context "when there is no data" do
      let(:error_object) { Boundary::NoData.new "no heat pump data" }

      before do
        allow(use_case).to receive(:execute).and_raise error_object
      end

      it "raises the expcted error" do
        expect { task.invoke }.to raise_error Boundary::NoData
      end
    end
  end
end
