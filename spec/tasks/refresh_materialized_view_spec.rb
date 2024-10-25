describe "rake to refresh a materialized" do
  context "when calling the rake task" do
    subject(:task) { get_task("refresh_materialized_view") }

    let(:gateway) do
      instance_double(Gateway::MaterializedViewsGateway)
    end

    let(:use_case) do
      instance_double(UseCase::RefreshMaterializedView)
    end

    before do
      allow(Container).to receive(:refresh_materialized_views_use_case).and_return(use_case)
      allow(UseCase::RefreshMaterializedView).to receive(:new).with(gateway:).and_return use_case
      allow(use_case).to receive(:execute)
    end

    after(:all) do
      ENV["CONCURRENTLY"] = nil
      ENV["NAME"] = nil
    end

    context "when passing the correct parameters" do
      before do
        ENV["NAME"] = "mvw_name"
      end

      it "calls the rake without error" do
        expect { task.invoke }.not_to raise_error
        expect(use_case).to have_received(:execute).with(name: "mvw_name", concurrently: false).exactly(:once)
      end
    end

    context "when passing concurrently in the environment" do
      before do
        ENV["CONCURRENTLY"] = "true"
        ENV["NAME"] = "mvw_name"
        task.invoke
      end

      it "calls the use case to perform the refresh" do
        expect(use_case).to have_received(:execute).with(name: "mvw_name", concurrently: true).exactly(:once)
      end
    end

    context "when passing an incorrect view name" do
      before do
        ENV["NAME"] = "wrong_name"
        allow(use_case).to receive(:execute).and_raise Boundary::InvalidArgument.new("wrong_view")
      end

      it "calls the rake without error" do
        expect { task.invoke }.to raise_error(Boundary::InvalidArgument, /wrong_view/)
      end
    end
  end
end
