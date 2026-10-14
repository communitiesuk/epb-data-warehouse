class CreateVwExportDocumentsNi < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document, matched_uprn::bigint) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      JOIN countries co ON s.country_id = co.country_id
      WHERE co.country_code = 'NIR'
    SQL
  end

  def self.up
    execute "CREATE OR REPLACE VIEW vw_json_documents_ni_yesterday AS
    #{sql} AND (warehouse_created_at::date = CURRENT_DATE - 1 OR updated_at::date = (CURRENT_DATE - 1))"

    execute "CREATE OR REPLACE VIEW vw_export_documents_ni AS
    #{sql}"
  end

  def self.down; end
end
