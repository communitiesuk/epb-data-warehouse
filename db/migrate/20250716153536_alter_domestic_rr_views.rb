class AlterDomesticRrViews < ActiveRecord::Migration[7.0]
  def self.sql
    <<-SQL
    SELECT
           aav.assessment_id as rrn,
           items.sequence as IMPROVEMENT_ITEM,
                       items.improvement_details ->> 'improvement_number'  as IMPROVEMENT_ID,
                        items.indicative_cost as INDICATIVE_COST,
              CASE WHEN  (improvement_details -> 'improvement_texts') IS NULL THEN
             get_lookup_value('improvement_summary', (items.improvement_details ->> 'improvement_number'),  ad.document ->> 'assessment_type', s.schema_type )

                 ELSE (improvement_details -> 'improvement_texts' ->> 'improvement_summary')::varchar END
                  as improvement_summary_text,

            CASE WHEN (improvement_details -> 'improvement_texts') IS NULL THEN
            get_lookup_value('improvement_description', (items.improvement_details ->> 'improvement_number'),  ad.document ->> 'assessment_type', s.schema_type )::varchar
              ELSE (improvement_details -> 'improvement_texts' ->> 'improvement_description')::varchar END
                      as improvement_descr_text
        FROM assessment_attribute_values aav
        CROSS JOIN LATERAL json_to_recordset(CASE WHEN jsonb_typeof(json::jsonb) = 'array' THEN aav.json::json
              ELSE json_build_array(aav.json -> 'improvement')::json
            END) AS
          items(sequence integer, indicative_cost varchar, improvement_type varchar,improvement_category varchar,  improvement_details json  )
        JOIN assessment_documents ad
        ON ad.assessment_id = aav.assessment_id
        JOIN public.assessment_attributes aa on aa.attribute_id = aav.attribute_id
        JOIN (SELECT aav1.assessment_id, aav1.attribute_value as schema_type
                       FROM assessment_attribute_values aav1
                       JOIN public.assessment_attributes a1 on aav1.attribute_id = a1.attribute_id
                       WHERE a1.attribute_name = 'schema_type')  as s
                      ON s.assessment_id = aav.assessment_id

         JOIN assessments_country_ids aci on aav.assessment_id = aci.assessment_id
        join countries co on aci.country_id = co.country_id
        WHERE aa.attribute_name = 'suggested_improvements'
        AND  co.country_code IN ('EAW', 'ENG', 'WLS')
        AND  ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')#{'  '}
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
