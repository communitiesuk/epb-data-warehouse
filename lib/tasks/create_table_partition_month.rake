desc "Add a partition to the assessment_search table for the next month"
task :create_table_partition_month do
  table_name = ENV["TABLE_NAME"] || "assessment_search"
  start_date = (Time.now + 1.month).beginning_of_month
  end_date = start_date.next_month
  partition_name = "#{table_name}_y#{start_date.year}m#{start_date.month}"

  raise Boundary::InvalidArgument, "table #{table_name} is not found" unless AddPartition.table_exists?(table_name)

  sql = "CREATE TABLE IF NOT EXISTS #{partition_name} PARTITION OF #{table_name} FOR VALUES FROM ('#{start_date}') TO ('#{end_date}')"

  ActiveRecord::Base.connection.exec_query(sql)
end

class AddPartition
  def self.table_exists?(table_name)
    sql = <<-SQL
        SELECT EXISTS (
       SELECT FROM information_schema.tables#{' '}
       WHERE      table_name   = $1
       )
    SQL

    binding = [
      ActiveRecord::Relation::QueryAttribute.new(
        "table_name",
        table_name,
        ActiveRecord::Type::String.new,
      ),
    ]
    ActiveRecord::Base.connection.exec_query(sql, "SQL", binding).first["exists"]
  end
end
