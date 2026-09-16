class CreateCommercialNiRrViews < ActiveRecord::Migration[8.1]
  def self.sql_rr(additional_filter: "")
    <<~SQL
      WITH cte as (SELECT assessment_id, t.*,
                          document ->> 'related_rrn' as related_certificate_number
      FROM assessment_documents ad
      CROSS JOIN LATERAL (VALUES (1, 'SHORT', ad.document -> 'short_payback'),
        (2, 'MEDIUM', ad.document -> 'medium_payback'),
        (3, 'LONG', ad.document -> 'long_payback'),
        (4, 'OTHER',  ad.document -> 'other_payback')) AS t (pubseq, payback_type, rr_json)
      WHERE EXISTS (SELECT *
        FROM assessment_search s
        join countries co on s.country_id = co.country_id
      WHERE s.assessment_id = ad.assessment_id AND assessment_type = 'CEPC-RR'
      #{additional_filter}
      AND co.country_code = 'NIR')
      )
      SELECT assessment_id  as CERTIFICATE_NUMBER,
        PAYBACK_TYPE,
        row_number() OVER (PARTITION BY cte.assessment_id ORDER BY cte.pubseq) AS RECOMMENDATION_ITEM,
        recommendation_code,
        recommendation,
       related_certificate_number
      FROM cte
      CROSS JOIN  LATERAL jsonb_to_recordset(rr_json) items(co2_impact character varying, recommendation_code character varying, recommendation character varying)
    SQL
  end

  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_commercial_ni_rr_search"
    execute "CREATE MATERIALIZED VIEW mvw_commercial_ni_rr_search AS #{sql_rr} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_commercial_ni_rr_yesterday"
    execute "CREATE OR REPLACE VIEW vw_commercial_ni_rr_yesterday AS #{sql_rr(additional_filter: 'AND s.created_at::date = (CURRENT_DATE - 1)')}"
  end
end
