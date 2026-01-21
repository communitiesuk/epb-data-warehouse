namespace :one_off do
  desc "Delete SAP 15 certificates from assessment_search"
  task :delete_sap_15_assessment_search do
    Gateway::AssessmentSearchGateway.new
    sql = <<~SQL
              DELETE FROM assessment_search s
              WHERE EXISTS (
                  SELECT 1
                  FROM assessment_documents d
                  WHERE d.assessment_id = s.assessment_id
                    AND d.document ->> 'schema_type' = 'SAP-Schema-15.0'
      );

    SQL

    ActiveRecord::Base.connection.execute(sql)
  end
end
