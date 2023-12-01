-- Query for ADD (Analysis and Data Directorate)

-- sap (domestic part-L)
SELECT document ->> 'hashed_assessment_id' as assessment_id,
       document ->> 'schema_type' as schema_type
FROM assessment_documents
WHERE document ->> 'schema_type' IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
AND document ->> 'postcode' NOT LIKE 'BT%'
AND document->>'registration_date' between '2023-07-01' and '2023-09-30'
AND document -> 'opt_out' IS NULL;

-- lzc
SELECT
    ad.document ->> 'hashed_assessment_id'as assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    ad.document ->> 'schema_type' as schema_type,
    ad.document ->> 'lzc_energy_sources' as lzc_energy_sources
FROM assessment_documents ad
WHERE ad.document->>'registration_date' between '2023-07-01' and '2023-09-30'
AND ad.document ->> 'lzc_energy_sources' IS NOT NULL
AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
AND ad.document -> 'opt_out' IS NULL
AND ad.document ->> 'postcode' NOT LIKE 'BT%';

-- pv arrays
SELECT
    ad.document ->> 'hashed_assessment_id'as assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    pv_arrays ->> 'peak_power' as peak_power
FROM assessment_documents ad,
jsonb_array_elements(ad.document -> 'sap_energy_source' -> 'pv_arrays') pv_arrays
WHERE ad.document->>'registration_date' between '2023-07-01' and '2023-09-30'
AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
AND ad.document ->> 'postcode' NOT LIKE 'BT%'
AND ad.document -> 'opt_out' IS NULL;