desc "benchmark domestic search execution times"
task :benchmark_domestic_search do
  date_start = ENV["DATE_START"]
  date_end = ENV["DATE_END"]
  row_limit = ENV["ROW_LIMIT"]
  council = ENV["COUNCIL"].nil? ? nil : ENV["COUNCIL"].split(",").map(&:strip)
  count = ENV["COUNT"].nil? ? 1 : ENV["COUNT"].to_i
  ENV["BUCKET_NAME"] = ENV["UD_BUCKET_NAME"]
  s3_upload = ENV["S3_UPLOAD"].nil? ? false : true

  start_time = Time.now
  params = { date_start: date_start, date_end: date_end, council: council }
  params[:recommendations] = ENV["RECOMMENDATIONS"] unless ENV["RECOMMENDATIONS"].nil?

  if s3_upload
    Container.multipart_storage_gateway(stub_responses: false)
    use_case = Container.export_user_data_use_case
    count = 1
  else
    use_case = Container.domestic_search_use_case
    params[:row_limit] = row_limit
  end

  count.times do |_i|
    use_case.execute(**params)
  rescue Boundary::TerminableError => e
    puts e.exception
  else
    total_time = Time.now - start_time
    puts "Average execution time: #{total_time / count} seconds"
  end
end
