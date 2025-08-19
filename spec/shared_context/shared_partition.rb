shared_context "when partitioning a table" do
  def create_temp_table
    sql = <<~SQL
          create table assessment_search_temp
      (
          assessment_id  varchar,
          registration_date  timestamp with time zone

      )
      PARTITION BY RANGE (registration_date)
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def add_partitions
    ActiveRecord::Base.connection.execute("SELECT fn_create_day_month_partition('assessment_search_temp', 2025)::varchar").first
  end

  def drop_temp_table
    ActiveRecord::Base.connection.exec_query("DROP TABLE assessment_search_temp")
  end

  def get_partitions
    let(:partitions) do
      sql = <<~SQL
               SELECT
            child.relname       AS child
        FROM pg_inherits
            JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
            JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
        #{'   '}
        WHERE parent.relname='assessment_search_temp';
        #{'    '}
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |i| i["child"] }.sort!
    end
  end
end
