require_relative "../../shared_context/shared_partition"

describe "Create Partition" do
  include_context "when partitioning a table"

  context "when calling the function to create a partition on a table" do
    let(:table_name) { "assessment_search_temp" }
    let(:partitions) do
      get_partitions(table_name)
    end
    let(:insert_row) do
      sql = <<~SQL
        INSERT INTO assessment_search_temp(assessment_id, registration_date)
        VALUES ('1',  make_date(2012, 1, 1)),
                ('2',  make_date(2025, 12, 1))

      SQL
      ActiveRecord::Base.connection.exec_query(sql)
    end

    before do
      create_temp_table(table_name)
      ActiveRecord::Base.connection.execute("SELECT fn_create_day_month_partition('assessment_search_temp', 2025)::varchar").first
    end

    after { ActiveRecord::Base.connection.exec_query("DROP TABLE assessment_search_temp") }

    it "the table has a partition for every month-year" do
      expect(partitions.length).to eq 168
    end

    it "the partition names match the oldest date range 2012-01" do
      expect(partitions.first).to eq "assessment_search_temp_y2012m1"
    end

    it "the partition names match the newest date range 2025-12" do
      expect(partitions).to include "assessment_search_temp_y2025m12"
    end

    it "can add a row into the relevant partition" do
      expect { insert_row }.not_to raise_error
    end

    context "when inserting a row that is out of the partition range" do
      let(:insert_row) do
        sql = <<~SQL
          INSERT INTO assessment_search_temp(assessment_id, registration_date)
          VALUES ('1',  make_date(2026, 1, 1))

        SQL
        ActiveRecord::Base.connection.exec_query(sql)
      end

      it "raises a SQL error" do
        expect { insert_row }.to raise_error ActiveRecord::StatementInvalid
      end
    end
  end
end
