namespace :one_off do
  desc "Update uprn in assessment_search with assessment_address_id data"
  task :update_uprn_assessment_search do
    Gateway::AssessmentSearchGateway.new
    sql = <<-SQL
        UPDATE assessment_search
        SET uprn =  CASE WHEN starts_with(assessment_address_id, 'UPRN') THEN  REPLACE(assessment_address_id,  'UPRN-', '')::BIGINT
            ELSE null END
        WHERE uprn IS NULL
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
