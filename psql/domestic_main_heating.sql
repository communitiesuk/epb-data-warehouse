SELECT   (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating
FROM assessment_documents ad
WHERE ad.document ->> 'assessment_type' = 'SAP'
  AND (nullif(document->>'registration_date', '')::date) > ('2021-07-01 00:00':: timestamp)
  AND (nullif(document->>'registration_date', '')::date) < ('2022-06-3 00:00':: timestamp)