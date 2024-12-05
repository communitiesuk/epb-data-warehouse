SELECT
ad.assessment_id as assessment_id,
ad.document ->> 'hashed_assessment_id' as hashed_assessment_id,
ad.document ->> 'calculation_tool' as calculation_tool,
ad.document ->> 'methodology' as methodology,
ad.document ->> 'output_engine' as output_engine,
ad.document ->> 'schema_type' as schema_type,
ad.document ->> 'assessment_address_id' as assessment_address_id,
ad.document ->> 'address_line_1' as address_line_1,
ad.document ->> 'address_line_2' as address_line_2,
ad.document ->> 'address_line_3' as address_line_3,
ad.document ->> 'post_town' as town,
ad.document ->> 'postcode' as postcode,
ad.document ->> 'created_at' as lodgement_date_time,
ad.document ->> 'registration_date' as registration_date,
ad.document ->> 'asset_rating' as asset_rating,
ad.document ->> 'property_type' as property_type,
ad.document ->> 'report_type' as report_type,
ad.document ->> 'transaction_type' as transaction_type
FROM assessment_documents ad
JOIN assessments_country_ids aci ON ad.assessment_id = aci.assessment_id
JOIN countries c ON c.country_id = aci.country_id
WHERE c.country_code IN ('ENG', 'EAW', 'WLS')
AND (ad.document ->> 'assessment_type')::varchar = 'CEPC'
AND ad.document -> 'opt_out' IS NULL
AND (ad.document->>'registration_date' BETWEEN '2009-01-01' AND '2009-12-31');