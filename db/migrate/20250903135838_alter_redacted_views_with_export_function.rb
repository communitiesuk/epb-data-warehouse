class AlterRedactedViewsWithExportFunction < ActiveRecord::Migration[7.0]
  def self.sql(year)
    <<~SQL
      CREATE OR REPLACE VIEW vw_domestic_documents_#{year} AS
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      JOIN ( VALUES ('SAP'), ('RdSAP') ) vals (t) ON (s.assessment_type = t)
      WHERE EXTRACT(YEAR FROM s.registration_date) = #{year}
    SQL
  end

  def self.up
    years = (2012..2025).to_a
    years.each do |year|
      sql = sql(year)
      execute(sql)
    end
  end

  def self.down; end
end
