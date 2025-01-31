desc "benchmark domestic search execution times"
task :benchmark_domestic_search do
  date_start = ENV["DATE_START"]
  date_end = ENV["DATE_END"]
  row_limit = ENV["ROW_LIMIT"]
  council = ENV["COUNCIL"]
  count = ENV["COUNT"].nil? ? 1 : ENV["COUNT"].to_i
  s3_upload = ENV["S3_UPLOAD"].nil? ? false : true

  start_time = Time.now

  if s3_upload
    use_case = Container.export_user_data_use_case
    begin
      use_case.execute(date_start:, date_end:, council:)
    rescue Boundary::InvalidDates => e
      raise e
    end
  else
    use_case = Container.domestic_search_use_case
    count.times do |_i|
      use_case.execute(date_start:, date_end:, row_limit:, council:)
    rescue Boundary::InvalidDates => e
      raise e
    end
  end

  total_time = Time.now - start_time

  puts "Average execution time: #{total_time / count} seconds"
end
