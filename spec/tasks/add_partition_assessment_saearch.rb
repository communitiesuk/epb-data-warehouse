require_relative "../shared_context/shared_partition"

describe "Add a partition to the assessment_search table for next month" do
  include_context "when partitioning a table"

  context "when calling the rake task" do
    subject(:task) { get_task("add_partition_assessment_search") }

    before do
      create_temp_table
    end

    after {
      drop_temp_table
      Timecop.return
    }



    context "when the current date is Aug 2025" do
      before do
        task.invoke
      end

      it "adds a partition for Sept 2025" do
        expect(get_partitions.count).to eq(1)
      end
    end
  end
end
