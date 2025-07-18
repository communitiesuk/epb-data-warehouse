namespace :one_off do
  desc "Apply addition of hashed_assessment_id by updating the document store and EAV table with a new data node or row"
  task :backfill_assessment_search do
    start_date = ENV["START_DATE"]
    end_date = ENV["END_DATE"]

    date_range_sql = ""
    if !start_date.nil? && !end_date.nil?
      date_range_sql = "AND d.document ->> 'registration_date' BETWEEN '#{start_date}' AND '#{end_date}'"
    end
    assessment_search_gateway = Gateway::AssessmentSearchGateway.new

    sql = <<-SQL
      SELECT d.assessment_id, aci.country_id
      FROM assessment_documents d
      LEFT JOIN assessments_country_ids aci ON d.assessment_id = aci.assessment_id
      WHERE NOT (
        EXISTS (SELECT 1
                FROM assessment_attribute_values aav
                         JOIN assessment_attributes aa
                              ON aav.attribute_id = aa.attribute_id
                WHERE aa.attribute_name = 'opt_out'
                  AND aav.assessment_id = d.assessment_id)
            OR EXISTS (SELECT ase.assessment_id
                        FROM assessment_search ase
                        WHERE ase.assessment_id = d.assessment_id)
      )
      AND d.document ->> 'assessment_type' != 'AC-CERT'
      AND aci.country_id IN (1, 2, 4)
      #{date_range_sql}
    SQL

    count_sql = "SELECT COUNT(*) FROM (#{sql}) as a"
    count = ActiveRecord::Base.connection.select_value(count_sql).to_i

    if count.zero?
      puts "No certificates to backfill — exiting early."
      next
    else
      puts "Total assessments to backfill: #{count}"
    end

    raw_connection = ActiveRecord::Base.connection.raw_connection
    raw_connection.send_query(sql)
    raw_connection.set_single_row_mode

    return if count.eql? 0

    raw_connection.get_result.stream_each.map { |row| { assessment_id: row["assessment_id"], document: row["document"], country_id: row["country_id"], created_at: row["created_at"] } }.each_slice(500) do |assessments|
      assessments.each do |assessment|
        document = Helper::BackFillTask.document(assessment[:assessment_id])
        created_at = document["created_at"].nil? ? document["registration_date"] : document["created_at"]
        assessment_search_gateway.insert_assessment(assessment_id: assessment[:assessment_id], document:, country_id: assessment[:country_id], created_at:)
      end
    end
    puts "All certificates have been backfilled"
    ActiveRecord::Base.connection.close
  end
end

class Helper::BackFillTask
  def self.document(assessment_id)
    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]

    doc = ActiveRecord::Base.connection.exec_query("SELECT document FROM assessment_documents WHERE assessment_id =$1", "SQL", bindings).first["document"]
    JSON.parse(doc)
  end
end
