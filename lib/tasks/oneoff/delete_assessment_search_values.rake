namespace :one_off do
  desc "delete any rows from assessment_search that were added before cancelled.opt queues were updated"
  task :delete_assessment_search_values do
    sql = <<~SQL
      DELETE#{' '}
      FROM assessment_search l
      USING audit_logs  a
      WHERE a.assessment_id = l.assessment_id
      AND event_type IN ('cancelled', 'opt_out')
      #{' '}
    SQL

    ActiveRecord::Base.connection.exec_query(sql, "SQL")
  end
end
