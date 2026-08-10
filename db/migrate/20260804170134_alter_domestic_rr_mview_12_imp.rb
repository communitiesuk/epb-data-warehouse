class AlterDomesticRrMview12Imp < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
          select
          ad.assessment_id as certificate_number,
          (elem ->> 'sequence')::int as IMPROVEMENT_ITEM,
          elem -> 'improvement_details' ->> 'improvement_number'  as IMPROVEMENT_ID,
          elem ->> 'indicative_cost' as INDICATIVE_COST,
          COALESCE(
                  elem ->> 'improvement_summary',
                  elem -> 'improvement_details' -> 'improvement_texts' ->> 'improvement_summary',
                  get_lookup_value('improvement_summary', (elem -> 'improvement_details' ->> 'improvement_number'),
                                   ad.document ->> 'assessment_type', ad.document ->> 'schema_type')
          ) as improvement_summary_text,
          COALESCE(
                  elem ->> 'improvement_description',
                  elem -> 'improvement_details' -> 'improvement_texts' ->> 'improvement_description',
                  get_lookup_value('improvement_description', (elem -> 'improvement_details' ->> 'improvement_number'),
                                   ad.document ->> 'assessment_type', ad.document ->> 'schema_type')
          ) as improvement_descr_text
      from assessment_documents ad
          join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
          join countries co on co.country_id = aci.country_id
          cross join lateral jsonb_array_elements(ad.document -> 'suggested_improvements') AS elem
      where co.country_code IN ('EAW', 'ENG', 'WLS')
          AND  ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
          AND ad.document ->> 'suggested_improvements' is not null
    SQL
  end

  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_rr_search"
    execute "CREATE MATERIALIZED VIEW mvw_domestic_rr_search as #{sql} WITH NO DATA;"

    execute "DROP VIEW IF EXISTS vw_domestic_rr_yesterday"
    execute "CREATE VIEW vw_domestic_rr_yesterday as #{sql} AND ad.warehouse_created_at::date = CURRENT_DATE - 1;;"
  end

  def self.down; end
end
