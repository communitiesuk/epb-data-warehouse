desc "refresh average co2 emissions materalized view"
task :refresh_average_co2_emissions do
  concurrently = ENV["CONCURRENTLY"].nil? ? false : true

  Container.refresh_average_co2_emissions.execute(concurrently:)
end
