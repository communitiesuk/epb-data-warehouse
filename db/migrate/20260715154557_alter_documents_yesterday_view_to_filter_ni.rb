class AlterDocumentsYesterdayViewToFilterNi < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
      CREATE OR REPLACE VIEW vw_json_documents_yesterday AS
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document, matched_uprn::bigint) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      JOIN countries co ON s.country_id = co.country_id
      WHERE (warehouse_created_at::date = CURRENT_DATE - 1 OR updated_at::date = (CURRENT_DATE - 1))
      AND co.country_code in ('EAW', 'ENG', 'WLS');
    SQL
  end

  def self.up
    execute(sql)
  end

  def self.down; end
end
