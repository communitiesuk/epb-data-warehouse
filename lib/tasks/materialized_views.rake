desc "refresh a materialized view"
task :refresh_materialized_view do
  name = ENV["NAME"]
  concurrently = ENV["CONCURRENTLY"].nil? ? false : true

  Container.refresh_materialized_views_use_case.execute(name:, concurrently:)
end
