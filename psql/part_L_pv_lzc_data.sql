-- Query for ADD (Analysis and Data Directorate)

-- sap (domestic part-L) updated Jan 2025
SELECT document ->> 'hashed_assessment_id' as hashed_assessment_id,
    ad.assessment_id as assessment_id,
    document ->> 'schema_type' as schema_type,
    document ->> 'registration_date' as registration_date,
    document ->> 'sap_version' as sap_version,
    document ->> 'sap_data_version' as sap_data_version,
    document ->> 'country_code' as country_code
FROM assessment_documents ad
  WHERE (ad.document ->> 'assessment_type')::varchar = 'SAP'
  AND document ->> 'country_code' IN ('ENG', 'WLS', 'EAW')
  AND document->>'registration_date' between '2024-01-01' and '2024-12-31';

-- lzc updated Jan 2025
SELECT
    ad.document ->> 'hashed_assessment_id'as hashed_assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    ad.document ->> 'schema_type' as schema_type,
    ad.document ->> 'lzc_energy_sources' as lzc_energy_sources,
    ad.document ->> 'country_code' as country_code
FROM assessment_documents ad
WHERE ad.document->>'registration_date' between '2024-01-01' and '2024-12-31'
  AND ad.document ->> 'lzc_energy_sources' IS NOT NULL
  AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
  AND document ->> 'country_code' IN ('ENG', 'WLS', 'EAW');

-- pv arrays updated Jan 2025
SELECT
    ad.document ->> 'hashed_assessment_id'as hashed_assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    pv_arrays ->> 'peak_power' as peak_power,
    pv_arrays ->> 'orientation' as orientation,
    pv_arrays ->> 'pitch' as pitch,
    pv_arrays ->> 'overshading' as overshading,
    pv_arrays ->> 'overshading_mcs' as overshading_mcs,
    pv_arrays ->> 'mcs_certificate' as mcs_certificate,
    pv_arrays ->> 'mcs_certificate_reference' as mcs_certificate_reference,
    pv_arrays ->> 'pv_panel_manufacturer_name' as pv_panel_manufacturer_name,
    ad.document ->> 'country_code' as country_code
FROM assessment_documents ad,
    jsonb_array_elements(ad.document -> 'sap_energy_source' -> 'pv_arrays') pv_arrays
WHERE ad.document->>'registration_date' between '2024-01-01' and '2024-12-31'
  AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
  AND document ->> 'country_code' IN ('ENG', 'WLS', 'EAW');