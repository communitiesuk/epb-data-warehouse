describe "test domestic search benchmarking rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("benchmark_domestic_search") }

    let(:use_case) do
      instance_double(UseCase::DomesticSearch)
    end

    let(:gateway) do
      instance_double(Gateway::DomesticSearchGateway)
    end

    before do
      allow(Container).to receive(:domestic_search_use_case).and_return(use_case)
      allow(UseCase::DomesticSearch).to receive(:new).with(gateway:).and_return use_case
      allow(use_case).to receive(:execute)
    end

    after(:all) do
      ENV["DATE_START"] = nil
      ENV["DATE_END"] = nil
      ENV["ROW_LIMIT"] = nil
      ENV["COUNCIL"] = nil
    end

    it "call the rake without errors" do
      expect { task.invoke }.not_to raise_error
      expect(use_case).to have_received(:execute).exactly(:once)
    end

    context "when passing the correct parameters" do
      before do
        ENV["DATE_START"] = "2000-12-31"
        ENV["DATE_END"] = "2024-12-31"
        ENV["ROW_LIMIT"] = "2"
        ENV["COUNCIL"] = "Manchester"
      end

      it "calls the rake without error" do
        expect { task.invoke }.not_to raise_error
        expect(use_case).to have_received(:execute).with(date_start: "2000-12-31", date_end: "2024-12-31", row_limit: "2", council: "Manchester").exactly(:once)
      end
    end
  end
end
