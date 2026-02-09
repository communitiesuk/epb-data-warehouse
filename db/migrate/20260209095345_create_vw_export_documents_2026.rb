class CreateVwExportDocuments2026 < ActiveRecord::Migration[8.1]
  def self.up
    execute "CREATE OR REPLACE VIEW vw_export_documents_2026 AS
    SELECT ad.assessment_id AS certificate_number,
           fn_export_json_document(document) AS document,
           warehouse_created_at,
           updated_at,
           s.assessment_type,
           EXTRACT(YEAR FROM s.registration_date)::integer AS year
    FROM assessment_documents ad
    JOIN assessment_search s ON s.assessment_id=ad.assessment_id
    WHERE EXTRACT(YEAR FROM s.registration_date) = 2026"
  end

  def self.down; end
end
