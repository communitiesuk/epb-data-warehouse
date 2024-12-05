require "net/http"

desc "make http request to existing open data API"
task :open_date_api do
  paginator = "none"
  rake_start = Time.now
  number_requests = 0
  loop do
    base_url = "https://epc.opendatacommunities.org/api/v1/"
    path = "#{base_url}domestic/search?size=5000&from-month=5&from-year=2024&to-month=6&to-year=2024"
    unless paginator == "none"
      path += "&search-after=#{paginator}"
    end
    uri = URI(path)
    req = Net::HTTP::Get.new(uri)
    req["Accept"] = "application/json"
    req["Authorization"] = "Basic #{ENV['ode_api_key']}"
    start = Time.now

    pp "--REQUESTS starting---"
    pp "Uri: #{path}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    number_requests += 1
    now = Time.now
    pp "--RESPONSE COMPLETED---"
    puts "Elapsed time:#{now - start} seconds"
    paginator = res["X-Next-Search-After"]

    break if paginator.nil? || paginator.empty? || paginator == " "

  end
  pp "--- DOWNLOAD COMPLETE ---"
  pp "Number requests: #{number_requests}"
  pp "Total Elapsed time: #{Time.new - rake_start} seconds"
end
