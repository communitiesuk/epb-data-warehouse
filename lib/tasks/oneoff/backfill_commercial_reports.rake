namespace :one_off do
  desc "Populate commercial_reports table with data from Register DB"
  task :backfill_commercial_reports do
    ActiveRecord::Base.transaction do
      sql = <<-SQL
      INSERT INTO commercial_reports(assessment_id, related_rrn)
      SELECT ad.assessment_id, ad.document ->> 'related_rrn' AS related_rrn
      FROM assessment_documents ad
      JOIN assessment_search a ON a.assessment_id = ad.assessment_id
      WHERE ad.document ->> 'assessment_type' IN ('CEPC', 'DEC')
      AND ad.document ->> 'related_rrn' IS NOT NULL
      AND NOT EXISTS (
          SELECT *
          FROM commercial_reports cr
          WHERE cr.assessment_id = ad.assessment_id
      )
      SQL

      ActiveRecord::Base.connection.exec_insert(sql)
    end

    ActiveRecord::Base.connection.close
  end
end
