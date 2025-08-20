desc "Add a partition to the assessment_search table for the next month"
task :create_table_partition_month do
  table_name = ENV["TABLE_NAME"] || "assessment_search"
  date_next_month = (Time.now + 1.month)
  next_month   =  date_next_month.month
  this_year    = Time.now.month < 12 ? Time.now.year : Time.now.year + 1
  partition_name = "#{table_name}_y#{this_year}m#{next_month}"
  start_date  = Time.new(this_year, next_month, 1)
  end_date    = Time.new(this_year, next_month + 1, 1)

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
