desc "Add a partition to the assessment_search table for next month"
task :add_partition_assessment_search do
  table_name = ENV["TABLE_NAME"] || "assessment_search"
  date_next_month = (Time.now + 1.month)
  next_month   =  date_next_month.month
  this_year    = Time.now.month < 12 ? Time.now.year : Time.now.year + 1
  partition_name = "#{table_name}_y#{this_year}m#{next_month}"
  start_date  = Time.new(this_year, next_month, 1)
  end_date    = Time.new(this_year, next_month + 1, 1)

  sql = "CREATE TABLE IF NOT EXISTS #{partition_name} PARTITION OF #{table_name} FOR VALUES FROM ('#{start_date}') TO ('#{end_date}')"

  ActiveRecord::Base.connection.exec_query(sql)
end
