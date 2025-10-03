require_relative "../../helper/back_fill_task"

namespace :one_off do
  desc "Populate commercial_reports table with data from Register DB"
  task :backfill_commercial_reports do
    commercial_reports_gateway = Gateway::CommercialReportsGateway.new
    count = 0

    sql = <<-SQL
      SELECT ad.assessment_id, ad.document ->> 'related_rrn' AS related_rrn
      FROM assessment_documents ad
      WHERE ad.document ->> 'assessment_type' IN ('CEPC', 'DEC')
      AND ad.document ->> 'related_rrn' IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM commercial_reports cr
        WHERE cr.assessment_id = ad.assessment_id
      )
    SQL

    raw_connection = ActiveRecord::Base.connection.raw_connection
    raw_connection.send_query(sql)
    raw_connection.set_single_row_mode

    raw_connection.get_result.stream_each.map { |row| { assessment_id: row["assessment_id"], related_rrn: row["related_rrn"] } }.each_slice(500) do |reports|
      reports.each do |report|
        commercial_reports_gateway.insert_report(assessment_id: report[:assessment_id], related_rrn: report[:related_rrn])
        count += 1
      rescue NoMethodError
        # Ignored
      end
    end

    puts "Total assessments to back fill: #{count}"
    ActiveRecord::Base.connection.close
  end
end
