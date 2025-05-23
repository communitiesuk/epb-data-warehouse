describe "test domestic search benchmarking rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("benchmark_domestic_search") }

    let(:use_case) do
      instance_double(UseCase::DomesticSearch)
    end

    let(:storage_gateway) do
      Gateway::MultipartStorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses: true)
    end

    let(:gateway) do
      instance_double(Gateway::DomesticSearchGateway)
    end

    before do
      allow(Container).to receive_messages(domestic_search_use_case: use_case)
      allow(use_case).to receive(:execute)
      allow($stdout).to receive(:puts)
    end

    after(:all) do
      ENV["DATE_START"] = nil
      ENV["DATE_END"] = nil
      ENV["ROW_LIMIT"] = nil
      ENV["COUNCIL"] = nil
    end

    it "call the rake without errors" do
      ENV["ROW_LIMIT"] = "1"
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

      after(:all) do
        ENV["S3_UPLOAD"] = nil
        ENV["COUNT"] = nil
        ENV["RECOMMENDATIONS"] = nil
      end

      it "calls the rake and passes the arguments to the use case" do
        expect { task.invoke }.not_to raise_error
        expect(use_case).to have_received(:execute).with(date_start: "2000-12-31", date_end: "2024-12-31", row_limit: "2", council: %w[Manchester]).exactly(:once)
      end

      it "prints the expected output" do
        expect { task.invoke }.to output(/Average execution time:/).to_stdout
      end

      it "calls the use case multiple times" do
        ENV["COUNT"] = "5"
        task.invoke
        expect(use_case).to have_received(:execute).exactly(5).times
      end
    end

    context "when passing wrong parameters" do
      before do
        ENV["DATE_START"] = "2000-12-31"
        ENV["DATE_END"] = "2024-12-31"
        ENV["ROW_LIMIT"] = "2"
        ENV["COUNCIL"] = "Manchester"
        allow(use_case).to receive(:execute).and_raise(Boundary::InvalidDates)
      end

      it "calls the rake with wrong dates and raises an error" do
        ENV["DATE_START"] = "2024-12-31"
        ENV["DATE_END"] = "2000-12-31"
        expect { task.invoke }.to output("date_from cannot be greater than date_to\n").to_stdout
      end
    end

    context "when there are no search results" do
      before do
        ENV["DATE_START"] = "2000-12-31"
        ENV["DATE_END"] = "2024-12-31"
        ENV["COUNCIL"] = "Manchester"
        allow(use_case).to receive(:execute).and_raise Boundary::NoData, "Domestic Search query"
      end

      it "calls the rake to do an empty search" do
        ENV["DATE_START"] = "2024-12-31"
        ENV["DATE_END"] = "2000-12-31"
        expect { task.invoke }.to output("There is no data return for 'Domestic Search query'\n").to_stdout
      end
    end

    context "when passing no row limit" do
      before do
        ENV["DATE_START"] = "2000-12-31"
        ENV["DATE_END"] = "2024-12-31"
        ENV["COUNCIL"] = "Manchester"
        allow(use_case).to receive(:execute)
      end

      it "does not raise an error" do
        expect { task.invoke }.not_to raise_error
      end
    end
  end
end
