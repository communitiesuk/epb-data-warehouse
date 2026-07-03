namespace :one_off do
  desc "Add historic month partitions to tables"
  task :create_historic_table_partitions do
    table_name = ENV.fetch("TABLE_NAME")
    from_date = Date.parse(ENV.fetch("PARTITIONS_START_DATE"))
    to_date = Date.parse(ENV.fetch("PARTITIONS_END_DATE"))

    (from_date.beginning_of_month..to_date.beginning_of_month)
      .select { |d| d.day == 1 }
      .each do |start_date|
        partition_name = "#{table_name}_y#{start_date.year}m#{start_date.month}"
        end_date = start_date.next_month

        ActiveRecord::Base.connection.exec_query(<<~SQL.squish)
          CREATE TABLE IF NOT EXISTS #{partition_name}
          PARTITION OF #{table_name}
          FOR VALUES FROM ('#{start_date.iso8601}') TO ('#{end_date.iso8601}')
        SQL
      end
  end
end
