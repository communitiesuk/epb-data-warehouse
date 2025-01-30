desc "benchmark domestic search execution times"
task :benchmark_domestic_search do
  date_start = ENV["DATE_START"]
  date_end = ENV["DATE_END"]
  row_limit = ENV["ROW_LIMIT"]
  council = ENV["COUNCIL"]
  count = ENV["COUNT"].nil? ? 1 : ENV["COUNT"].to_i

  use_case = Container.domestic_search_use_case
  start_time = Time.now
  count.times do |_i|
    use_case.execute(date_start:, date_end:, row_limit:, council:)
  rescue Boundary::InvalidDates => e
    raise e
  end

  total_time = Time.now - start_time

  puts "Average execution time: #{total_time / count} seconds"
end
