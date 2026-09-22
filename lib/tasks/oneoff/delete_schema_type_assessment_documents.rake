namespace :one_off do
  desc "Delete certificates from assessment_documents for a schema type"
  task :delete_schema_type_assessment_documents do
    schema_type = ENV["SCHEMA_TYPE"]

    sql = <<~SQL
      DELETE FROM assessment_documents d
      WHERE d.document ->> 'schema_type' = ?;
    SQL

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([sql, schema_type])

    ActiveRecord::Base.connection.execute(sanitized_sql)
  end
end
