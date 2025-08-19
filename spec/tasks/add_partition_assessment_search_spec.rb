require_relative "../shared_context/shared_partition"

describe "Add a partition to the assessment_search table for next month" do
  include_context "when partitioning a table"

  context "when calling the rake task" do
    subject(:task) { get_task("add_partition_assessment_search") }

    let(:table_name) { "test_table" }

    before do
      Timecop.travel(Date.parse("2025-08-01 12:00:00"))
      create_temp_table(table_name)
      ENV["TABLE_NAME"] = table_name
    end

    after do
      Timecop.return
      drop_temp_table(table_name)
    end

    context "when the current date is Aug 2025" do
      it "adds a partition for Sept 2025" do
        task.invoke
        expect(get_partitions(table_name)).to include("test_table_y2025m9")
      end
    end

    context "when the partition already exists" do
      before do
        task.invoke
      end

      it "does not add a dupe" do
        task.invoke
        expect(get_partitions(table_name)).to eq ["test_table_y2025m9"]
      end

    end

    context "when the current date is Dec 2025" do
      before { Timecop.travel(Date.parse("2025-12-25 12:00:00")) }
      after { Timecop.return }

      let(:insert_row) do
        sql = <<~SQL
          INSERT INTO test_table(assessment_id, registration_date)
          VALUES ('1',  make_date(2026, 1, 1))

        SQL
        ActiveRecord::Base.connection.exec_query(sql)
      end

      it "adds a partition for Jan 2026" do
        task.invoke
        expect(get_partitions(table_name)).to include("test_table_y2026m1")
      end

      it "allow insertion without error" do
        task.invoke
        expect { insert_row }.not_to raise_error
      end
    end
  end
end
