desc "Add a partition to the assessment_search table for next month"
task :add_partition_assessment_search do
  ENV["TABALE_NAME"] || "assessment_search"
  future_date = (Time.now + 1.month)
  next_month   = ENV["NEXT_MONTH"] || future_date.strftime("%m")
  this_year    = ENV["YEAR"] || future_date.year

  pp next_month
  pp this_year
end
