class AlterDomesticRrMview12Imp < ActiveRecord::Migration[8.1]
  def self.sql
    <<-SQL
     SELECT aav.assessment_id AS certificate_number,
        items.sequence AS improvement_item,
        (items.improvement_details ->> 'improvement_number'::text) AS improvement_id,
        items.indicative_cost,
        COALESCE(
            items.improvement_summary,
            (items.improvement_details -> 'improvement_texts' ->> 'improvement_summary'),
            public.get_lookup_value('improvement_summary'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
        )::character varying AS improvement_summary_text,
        COALESCE(
            items.improvement_description,
            (items.improvement_details -> 'improvement_texts' ->> 'improvement_description'),
            public.get_lookup_value('improvement_description'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
        )::character varying AS improvement_descr_text
       FROM ((((((public.assessment_attribute_values aav
         CROSS JOIN LATERAL json_to_recordset(
            CASE
                WHEN (jsonb_typeof(aav."json") = 'array'::text) THEN (aav."json")::json
                ELSE json_build_array((aav."json" -> 'improvement'::text))
            END) items(
                sequence integer,
                indicative_cost character varying,
                improvement_type character varying,
                improvement_category character varying,
                improvement_details json,
                improvement_summary character varying,
                improvement_description character varying
            ))
         JOIN public.assessment_documents ad ON (((ad.assessment_id)::text = (aav.assessment_id)::text)))
         JOIN public.assessment_attributes aa ON ((aa.attribute_id = aav.attribute_id)))
         JOIN ( SELECT aav1.assessment_id,
                aav1.attribute_value AS schema_type
               FROM (public.assessment_attribute_values aav1
                 JOIN public.assessment_attributes a1 ON ((aav1.attribute_id = a1.attribute_id)))
              WHERE ((a1.attribute_name)::text = 'schema_type'::text)) s ON (((s.assessment_id)::text = (aav.assessment_id)::text)))
         JOIN public.assessments_country_ids aci ON (((aav.assessment_id)::text = (aci.assessment_id)::text)))
         JOIN public.countries co ON ((aci.country_id = co.country_id)))
      WHERE (((aa.attribute_name)::text = 'suggested_improvements'::text) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((ad.document ->> 'assessment_type'::text) = ANY (ARRAY['SAP'::text, 'RdSAP'::text])))
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
