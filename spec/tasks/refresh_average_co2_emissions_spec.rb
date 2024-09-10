describe "rake to call the materialized view refresh function for co2 emissions calculation" do
  context "when calling the rake task" do
    subject(:task) { get_task("refresh_average_co2_emissions") }

    let(:gateway) do
      instance_double(Gateway::AverageCo2EmissionsGateway)
    end

    let(:use_case) do
      instance_double(UseCase::RefreshAverageCo2Emissions)
    end

    before do
      allow(Container).to receive(:refresh_average_co2_emissions).and_return(use_case)
      allow(UseCase::RefreshAverageCo2Emissions).to receive(:new).with(gateway:).and_return use_case
      allow(use_case).to receive(:execute)
    end

    it "calls the use case to perform the refresh" do
      task.invoke
      expect(use_case).to have_received(:execute).with(concurrently: false).exactly(:once)
    end

    context "when passing concurrently in the environment" do
      before do
        ENV["CONCURRENTLY"] = "true"
        task.invoke
      end

      after do
        ENV["CONCURRENTLY"] = nil
      end

      it "calls the use case to perform the refresh" do
        expect(use_case).to have_received(:execute).with(concurrently: true).exactly(:once)
      end
    end
  end
end
