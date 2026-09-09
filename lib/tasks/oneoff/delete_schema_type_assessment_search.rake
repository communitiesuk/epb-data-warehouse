namespace :one_off do
  desc "Delete certificates from assessment_search for a schema type"
  task :delete_schema_type_assessment_search do
    schema_type = ENV["SCHEMA_TYPE"]

    Gateway::AssessmentSearchGateway.new
    sql = <<~SQL
      DELETE FROM assessment_search s
      WHERE EXISTS (
          SELECT 1
          FROM assessment_documents d
          WHERE d.assessment_id = s.assessment_id
            AND d.document ->> 'schema_type' = ?
      );
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([sql, schema_type])

    ActiveRecord::Base.connection.execute(sanitized_sql)
  end
end
