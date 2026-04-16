namespace :one_off do
  desc "Update the address in assessment_search to remove any alphanumeric characters"
  task :update_address_assessment_search do
    Gateway::AssessmentSearchGateway.new

    sql = <<-SQL
      UPDATE assessment_search
      SET address = REGEXP_REPLACE(address, '[^a-zA-Z0-9\s]', '', 'g');
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end
end
