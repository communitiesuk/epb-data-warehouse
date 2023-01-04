SELECT COUNT(DISTINCT assessment_id)
FROM (
SELECT Lower((jsonb_array_elements(ad.document -> ('main-heating')) ->> 'description')::varchar) as heating_types, assessment_id
FROM assessment_documents ad
WHERE 0=0
AND (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
AND (document ->> 'assessment_type')::varchar = 'RdSAP') as SAP
WHERE SAP.heating_types LIKE '%air source heat pump%';

SELECT COUNT(*)
FROM assessment_documents
 WHERE (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
  AND  (document ->> 'assessment_type')::varchar =  'RdSAP';


SELECT COUNT(*)
FROM assessment_documents
 WHERE (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
  AND  (document ->> 'assessment_type')::varchar =  'SAP';


SELECT COUNT(DISTINCT assessment_id)
FROM (
SELECT Lower((jsonb_array_elements(ad.document -> ('main-heating')) ->> 'description')::varchar) as heating_types, assessment_id
FROM assessment_documents ad
WHERE 0=0
AND (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
AND (document ->> 'assessment_type')::varchar = 'RdSAP') as SAP
WHERE SAP.heating_types LIKE '%ground source heat pump%';


SELECT COUNT(DISTINCT assessment_id)
FROM (
SELECT Lower((jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar) as heating_types, assessment_id
FROM assessment_documents ad
WHERE 0=0
AND (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
AND (document ->> 'assessment_type')::varchar = 'SAP') as SAP
WHERE SAP.heating_types LIKE '%air source heat pump%';


SELECT COUNT(DISTINCT assessment_id)
FROM (
SELECT Lower((jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar) as heating_types, assessment_id
FROM assessment_documents ad
WHERE 0=0
AND (nullif(document->>'registration_date', '')::date) > ('2022-06-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
AND (document ->> 'assessment_type')::varchar = 'SAP') as SAP
WHERE SAP.heating_types LIKE '%ground source heat pump%';