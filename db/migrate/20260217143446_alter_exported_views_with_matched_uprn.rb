class AlterExportedViewsWithMatchedUprn < ActiveRecord::Migration[8.1]
  def self.sql(view_name)
    <<~SQL
      CREATE OR REPLACE VIEW #{view_name} AS
      SELECT ad.assessment_id AS certificate_number,
             fn_export_json_document(document, matched_uprn::bigint) AS document,
             warehouse_created_at,
             updated_at,
             s.assessment_type,
             EXTRACT(YEAR FROM s.registration_date)::integer AS year
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id=ad.assessment_id
    SQL
  end

  def self.up
    years = (2012..2026).to_a
    years.each do |year|
      year_sql = sql("vw_export_documents_#{year}")
      year_sql << "WHERE EXTRACT(YEAR FROM s.registration_date) = #{year}"
      execute(year_sql)
    end

    yesterday_sql = sql("vw_json_documents_yesterday")
    yesterday_sql << "WHERE warehouse_created_at::date = CURRENT_DATE - 1 OR updated_at::date = (CURRENT_DATE - 1);"
    execute(yesterday_sql)

    execute "DROP FUNCTION IF EXISTS fn_export_json_document(jsonb)"
  end

  def self.down; end
end
