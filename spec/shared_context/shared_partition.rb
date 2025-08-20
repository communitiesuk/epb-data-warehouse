shared_context "when partitioning a table" do
  def create_temp_table(table_name)
    sql = <<~SQL
          CREATE TABLE IF NOT EXISTS #{table_name}
      (
          assessment_id  varchar,
          registration_date  timestamp with time zone

      )
      PARTITION BY RANGE (registration_date)
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def drop_temp_table(table_name)
    ActiveRecord::Base.connection.exec_query("DROP TABLE #{table_name}")
  end

  def get_partitions(table_name)
    sql = <<~SQL
      SELECT
          child.relname       AS child
      FROM pg_inherits
          JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
          JOIN pg_class child             ON pg_inherits.inhrelid   = child.oid
       WHERE parent.relname=$1
    SQL
    binding = [
      ActiveRecord::Relation::QueryAttribute.new(
        "table_name",
        table_name,
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", binding).map { |i| i["child"] }.sort!
  end
end
