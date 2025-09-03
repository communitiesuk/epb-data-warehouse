class AlterJsonYesterdayView < ActiveRecord::Migration[7.0]
  def self.up
    sql = <<~SQL
      CREATE OR REPLACE VIEW vw_json_documents_yesterday AS
      SELECT ad.assessment_id AS certificate_number,
              fn_export_json_document(document) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      WHERE warehouse_created_at::date = CURRENT_DATE - 1 OR updated_at::date = (CURRENT_DATE - 1);
    SQL

    execute(sql)
  end

  def self.down; end
end
