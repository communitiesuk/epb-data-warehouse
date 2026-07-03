require_relative "../shared_context/shared_partition"

describe "Add a partition to the assessment_search table for next month" do
  subject(:task) { get_task("one_off:create_historic_table_partitions") }

  include_context "when partitioning a table"

  let(:table_name) { "test_table" }

  before do
    create_temp_table(table_name)
    ENV["TABLE_NAME"] = table_name
  end

  after do
    drop_temp_table(table_name)
  end

  context "with valid envs" do
    it "adds partitions for each month inclusive" do
      ENV["PARTITIONS_START_DATE"] = "2024-12-01"
      ENV["PARTITIONS_END_DATE"] = "2025-03-01"
      task.invoke
      expect(get_partitions(table_name)).to eq %w[
        test_table_y2024m12
        test_table_y2025m1
        test_table_y2025m2
        test_table_y2025m3
      ]
    end

    it "adds a paritions with the correct start and end dates" do
      ENV["PARTITIONS_START_DATE"] = "2024-12-05"
      ENV["PARTITIONS_END_DATE"] = "2024-12-27"
      task.invoke
      # Insert at start and end of date range
      expect { ActiveRecord::Base.connection.exec_query(<<~SQL) }.not_to raise_error
        INSERT INTO test_table(assessment_id, registration_date)
        VALUES ('1', make_date(2024, 12, 1)), ('2', make_date(2024, 12, 31))
      SQL

      # Insert before partition date range
      expect { ActiveRecord::Base.connection.exec_query(<<~SQL) }.to raise_error ActiveRecord::CheckViolation
        INSERT INTO test_table(assessment_id, registration_date)
        VALUES ('1', make_date(2024, 11, 30))
      SQL

      # Insert after partition date range
      expect { ActiveRecord::Base.connection.exec_query(<<~SQL) }.to raise_error ActiveRecord::CheckViolation
        INSERT INTO test_table(assessment_id, registration_date)
        VALUES ('1', make_date(2025, 1, 1))
      SQL
    end

    context "when the partition already exists" do
      it "does not add a duplicate partition" do
        ENV["PARTITIONS_START_DATE"] = "2024-12-01"
        ENV["PARTITIONS_END_DATE"] = "2025-03-01"
        task.invoke
        task.reenable

        ENV["PARTITIONS_START_DATE"] = "2025-02-01"
        ENV["PARTITIONS_END_DATE"] = "2025-05-01"
        task.invoke

        expect(get_partitions(table_name)).to eq %w[
          test_table_y2024m12
          test_table_y2025m1
          test_table_y2025m2
          test_table_y2025m3
          test_table_y2025m4
          test_table_y2025m5
        ]
      end
    end
  end

  context "without a start date" do
    it "raises an error invalid argument error" do
      ENV.delete("PARTITIONS_START_DATE")
      ENV["PARTITIONS_END_DATE"] = "2025-03-01"

      expect { task.invoke }.to raise_error KeyError
    end
  end

  context "without a valid start date" do
    it "raises an error invalid argument error" do
      ENV["PARTITIONS_START_DATE"] = "foo"
      ENV["PARTITIONS_END_DATE"] = "2025-03-01"

      expect { task.invoke }.to raise_error Date::Error
    end
  end

  context "without an end date" do
    it "raises an error invalid argument error" do
      ENV["PARTITIONS_START_DATE"] = "2025-03-01"
      ENV.delete("PARTITIONS_END_DATE")

      expect { task.invoke }.to raise_error KeyError
    end
  end

  context "without a valid end date" do
    it "raises an error invalid argument error" do
      ENV["PARTITIONS_START_DATE"] = "2025-03-01"
      ENV["PARTITIONS_END_DATE"] = "foo"

      expect { task.invoke }.to raise_error Date::Error
    end
  end

  context "when the table passed in is not found" do
    it "raises an error invalid argument error" do
      ENV["TABLE_NAME"] = "blah"
      ENV["PARTITIONS_START_DATE"] = "2025-03-01"
      ENV["PARTITIONS_END_DATE"] = "2025-03-01"
      expect { task.invoke }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
