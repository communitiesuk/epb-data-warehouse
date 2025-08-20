require_relative "../shared_context/shared_partition"

describe "Add a partition to the assessment_search table for next month" do
  include_context "when partitioning a table"

  context "when calling the rake task" do
    subject(:task) { get_task("create_table_partition_month") }

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
        expect(get_partitions(table_name)).to eq ["test_table_y2025m9"]
      end
    end

    context "when the partition already exists" do
      before do
        task.invoke
      end

      it "does not add a duplicate partition" do
        task.invoke
        expect(get_partitions(table_name)).to eq %w[test_table_y2025m9]
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

      it "allows and insertion into the table without error" do
        task.invoke
        expect { insert_row }.not_to raise_error
      end
    end

    context "when the table passed in is not found" do
      before do
        ENV["TABLE_NAME"] = "blah"
      end

      it "raises an error invalid argument error" do
        expect { task.invoke }.to raise_error(Boundary::InvalidArgument)
      end
    end
  end
end
