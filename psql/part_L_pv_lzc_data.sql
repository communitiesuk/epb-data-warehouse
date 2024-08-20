-- Query for ADD (Analysis and Data Directorate)

-- sap (domestic part-L)
SELECT document ->> 'hashed_assessment_id' as assessment_id,
    document ->> 'schema_type' as schema_type
FROM assessment_documents
WHERE document ->> 'schema_type' IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
  AND document ->> 'country_code' IN ('ENG', 'WLS', 'EAW')
  AND document->>'registration_date' between '2024-04-01' and '2024-06-31'
  AND document -> 'opt_out' IS NULL;

-- lzc
SELECT
    ad.document ->> 'hashed_assessment_id'as assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    ad.document ->> 'schema_type' as schema_type,
    ad.document ->> 'lzc_energy_sources' as lzc_energy_sources
FROM assessment_documents ad
WHERE ad.document->>'registration_date' between '2024-04-01' and '2024-06-31'
  AND ad.document ->> 'lzc_energy_sources' IS NOT NULL
  AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
  AND ad.document -> 'opt_out' IS NULL
  AND ad.document ->> 'country_code' IN ('ENG', 'WLS', 'EAW');

-- pv arrays
SELECT
    ad.document ->> 'hashed_assessment_id'as assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    pv_arrays ->> 'peak_power' as peak_power
FROM assessment_documents ad,
    jsonb_array_elements(ad.document -> 'sap_energy_source' -> 'pv_arrays') pv_arrays
WHERE ad.document->>'registration_date' between '2024-04-01' and '2024-06-31'
  AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
  AND ad.document ->> 'country_code' IN ('ENG', 'WLS', 'EAW')
  AND ad.document -> 'opt_out' IS NULL;