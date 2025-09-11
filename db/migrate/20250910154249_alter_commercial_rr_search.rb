class AlterCommercialRrSearch < ActiveRecord::Migration[7.0]
  def self.sql
    <<~SQL
        WITH cte AS(
              SELECT items.*, assessment_id,
              REPLACE(attribute_name, '_payback', '') AS PAYBACK_TYPE,
              CASE REPLACE(aa.attribute_name, '_payback', '')
                  WHEN 'short' THEN 1
                  WHEN 'medium' THEN 2
                  WHEN 'long'   THEN 3
                  ELSE 4
              END AS score
              FROM assessment_attribute_values aav
              JOIN assessment_attributes aa on aav.attribute_id = aa.attribute_id
              CROSS JOIN LATERAL json_to_recordset(aav.json::json) as items(co2_impact varchar, recommendation_code varchar, recommendation varchar)
              WHERE aa.attribute_name LIKE '%payback%'
      )
      SELECT
          cte.assessment_id AS certificate_number,
          UPPER(cte.PAYBACK_TYPE) AS PAYBACK_TYPE,
          ROW_NUMBER() OVER (PARTITION BY cte.assessment_id ORDER BY cte.score) AS recommendation_item,
         (SELECT assessment_id FROM assessment_attribute_values aav1
           JOIN public.assessment_attributes aa on aav1.attribute_id = aa.attribute_id WHERE aav1.attribute_value = cte.assessment_id
          AND attribute_name = 'related_rrn') as RELATED_CERTIFICATE_NUMBER,
          cte.recommendation_code,
          cte.recommendation
      FROM cte
      JOIN assessment_search s ON cte.assessment_id = s.assessment_id AND s.assessment_type = 'CEPC-RR'
    SQL
  end

  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_commercial_rr_search"
    execute "CREATE MATERIALIZED VIEW mvw_commercial_rr_search AS
      #{sql} WITH NO DATA"

    execute "CREATE OR REPLACE VIEW vw_commercial_rr_yesterday AS
      #{sql} WHERE s.created_at::date = (CURRENT_DATE - 1)"
  end

  def self.down; end
end
