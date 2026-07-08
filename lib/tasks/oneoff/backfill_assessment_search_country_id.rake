namespace :one_off do
  desc "Backfill country_id in assessment_search table from assessment_documents"
  task :backfill_assessment_search_country_id do
    start_date = ENV["START_DATE"]
    end_date = ENV["END_DATE"]

    raise Boundary::ArgumentMissing, start_date.nil? ? "START_DATE" : "END_DATE" if (start_date.nil? && !end_date.nil?) || (!start_date.nil? && end_date.nil?)

    unless start_date.nil?
      begin
        raise ArgumentError if Date.parse(end_date) < Date.parse(start_date)
      rescue Date::Error
        raise ArgumentError
      end
    end

    date_range_sql = ""
    if !start_date.nil? && !end_date.nil?
      date_range_sql = "AND s.registration_date BETWEEN '#{Date.parse(start_date)}' AND '#{Date.parse(end_date)}'"
    end

    sql = <<-SQL
      UPDATE assessment_search s
      SET country_id = aci.country_id
      FROM assessments_country_ids aci
      WHERE (s.assessment_id = aci.assessment_id)
      AND s.country_id IS NULL
      #{date_range_sql};
    SQL

    result = ActiveRecord::Base.connection.exec_update(sql)
    puts "Updated #{result} rows in assessment_search"
  end
end
