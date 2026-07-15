class AlterExportedViewsToFilterNi < ActiveRecord::Migration[8.1]
  def self.sql(year)
    <<~SQL
      CREATE OR REPLACE VIEW vw_export_documents_#{year} AS
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document, matched_uprn::bigint) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
      JOIN countries co ON s.country_id = co.country_id
      WHERE EXTRACT(YEAR FROM s.registration_date) = #{year}
      AND co.country_code in ('EAW', 'ENG', 'WLS')
    SQL
  end

  def self.up
    years = (2011..2026).to_a
    years.each do |year|
      sql = sql(year)
      execute(sql)
    end
  end

  def self.down; end
end
