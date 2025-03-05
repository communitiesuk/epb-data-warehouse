describe "removing any duplicate attributes and updating attribute values" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:fix_attribute_duplicates") }

    let(:gateway) do
      instance_double(Gateway::AssessmentAttributesGateway)
    end

    let(:use_case) do
      instance_double(UseCase::FixAttributeDuplicates)
    end

    before do
      allow(Container).to receive(:fix_attribute_duplicates_use_case).and_return(use_case)
      allow(UseCase::FixAttributeDuplicates).to receive(:new).with(assessment_attribute_gateway: gateway).and_return use_case
      allow($stdout).to receive(:puts)
    end

    context "when there are no dupes" do
      before do
        allow(use_case).to receive(:execute).and_raise Boundary::NoData, "No data"
      end

      it "raises a no data error" do
        expect { task.invoke }.to raise_error Boundary::NoData
      end
    end

    context "when there are duplicated attributes" do
      before do
        allow(use_case).to receive(:execute).and_return 3
      end

      it "does not raises an error" do
        expect { task.invoke }.not_to raise_error
      end

      it "prints a count of number of attributes to be deleted" do
        expect { task.invoke }.to output(/There were 3 duplicated attributes fixed/).to_stdout
      end
    end
  end
end
