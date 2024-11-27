CREATE MATERIALIZED VIEW mvw_od_test_domestic
AS
SELECT
    assessment_id as LMK_KEY,
    document ->> 'address_line_1' as ADDRESS1,
    document ->> 'address_line_2' as ADDRESS2,
    document ->> 'address_line_3' as ADDRESS3,
    document ->> 'postcode' as POSTCODE,
    document ->> 'total_floor_area' as TOTAL_FLOOR_AREA,
    document->>'energy_rating_current' as CURRENT_ENERGY_RATING,
    document->>'registration_date' as LODGEMENT_DATE,
    os_la.name as LOCAL_AUTHORITY_LABEL,
    os_p.name as CONSTITUENCY_LABEL,
    get_lookup_value('transaction_type', document ->> 'transaction_type', document ->> 'assessment_type', document->> 'schema_type' ) as TRANSACTION_TYPE,
    get_lookup_value('property_type', document ->> 'property_type', document ->> 'assessment_type', document->> 'schema_type' ) as PROPERTY_TYPE,


    LOWER(CONCAT_WS(' ', (document ->> 'address_line_1')::varchar,
                    (document ->> 'address_line_2')::varchar,
                    (document ->> 'address_line_3')::varchar,
                    (document ->> 'post_town')::varchar)) as full_address

FROM assessment_documents
         left JOIN ons_postcode_directory ons on document ->> 'postcode' = ons.postcode
         left join ons_postcode_directory_names os_la on ons.local_authority_code = os_la.area_code
         left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
WHERE document ->> 'assessment_type' IN ('RdSAP', 'SAP')
  AND document ->> 'country_code' IN ('EAW', 'ENG', 'WLS')
WITH NO DATA;

REFRESH MATERIALIZED VIEW mvw_od_test_domestic;

CREATE EXTENSION pg_trgm;


CREATE INDEX IF NOT EXISTS idx_address_mvw_od_test_domestic_mw_trigram ON mvw_od_test_domestic USING gin (full_address  gin_trgm_ops)

SELECT *
FROM mvw_od_test_domestic
WHERE full_address LIKE '%london%'



