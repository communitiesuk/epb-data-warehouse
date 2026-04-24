namespace :one_off do
  desc "Update assessment_search.created_at to use the value from json doc"
  task :fix_assessment_search_created_at do
    sql = <<-SQL
     UPDATE assessment_search s
     SET created_at = (d.document ->> 'created_at')::timestamptz
      FROM assessment_documents d
     WHERE  (s.assessment_id = d.assessment_id)
       AND created_at != (d.document ->> 'created_at')::timestamptz
     AND s.created_at >= '2025-07-09'
    SQL

    ActiveRecord::Base.connection.exec_query(sql)
  end
end
