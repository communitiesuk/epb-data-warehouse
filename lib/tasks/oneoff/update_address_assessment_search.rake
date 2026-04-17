namespace :one_off do
  desc "Update address in assessment_search to remove commas and replace them with a white space"
  task :update_address_assessment_search do
    Gateway::AssessmentSearchGateway.new

    sql = <<-SQL
      UPDATE assessment_search
      SET address = REGEXP_REPLACE((REPLACE(address::TEXT, ',', ' ')),'\s+', ' ', 'g');
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end
end
