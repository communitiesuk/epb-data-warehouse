desc "benchmark domestic search execution times"
task :benchmark_domestic_search do
  date_start = ENV["DATE_START"]
  date_end = ENV["DATE_END"]
  row_limit = ENV["ROW_LIMIT"]
  council = ENV["COUNCIL"]
  count = ENV["COUNT"].nil? ? 1 : ENV["COUNT"].to_i

  raise Boundary::InvalidArgument, "Row limit must between 1 and 5000" unless row_limit.to_i.positive? || row_limit.to_i > 5000

  start_time = Time.now
  count.times do |_i|
    Container.domestic_search_use_case.execute(date_start:, date_end:, row_limit:, council:)
  rescue Boundary::InvalidDates => e
    raise e
  end

  total_time = Time.now - start_time

  puts "Average execution time: #{total_time / count} seconds"
end
