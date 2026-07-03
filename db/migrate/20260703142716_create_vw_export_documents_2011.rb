class CreateVwExportDocuments2011 < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE VIEW vw_export_documents_2011 AS
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document, matched_uprn::bigint) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      WHERE EXTRACT(YEAR FROM s.registration_date) = 2011
    SQL
  end
end
