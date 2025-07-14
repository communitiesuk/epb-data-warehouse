namespace :one_off do
  desc "Apply addition of hashed_assessment_id by updating the document store and EAV table with a new data node or row"
  task :backfill_assessment_search do
    assessment_search_gateway = Gateway::AssessmentSearchGateway.new

    sql = <<-SQL
      SELECT d.assessment_id, d.document, aci.country_id
      FROM assessment_documents d
      LEFT JOIN assessments_country_ids aci ON d.assessment_id = aci.assessment_id
      WHERE NOT EXISTS (
        SELECT 1
        FROM assessment_attribute_values aav
        JOIN assessment_attributes aa
          ON aav.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'opt_out'
          AND aav.assessment_id = d.assessment_id
      )  
    SQL

    raw_connection = ActiveRecord::Base.connection.raw_connection
    raw_connection.send_query(sql)
    raw_connection.set_single_row_mode

    raw_connection.get_result.stream_each.map { |row| { assessment_id: row["assessment_id"], document: row["document"], country_id: row["country_id"] } }.each_slice(500) do |assessments|
      assessments.each do |assessment|
        document = JSON.parse(assessment[:document])

        pp assessment[:assessment_id]
        pp assessment[:country_id]

        assessment_search_gateway.insert_assessment(assessment_id: assessment[:assessment_id], document:, country_id: assessment[:country_id])
      end
    end
  end
end