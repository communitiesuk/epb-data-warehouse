SELECT  ad.document ->> 'assessment_type' as assessment_type, COUNT(*) as num_epcs
FROM assessment_documents ad
    JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
  AND (nullif(document->>'registration_date', '')::date) > ('2021-04-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-03-31 00:00':: timestamp)
  AND ons.areas ->> 'pcon18cd' = 'E14001011'
GROUP BY  ad.document ->> 'assessment_type';
--number of SAP/RdSAP for walsall still

SELECT COUNT(*),  ad.document ->> 'assessment_type'
FROM assessment_documents ad
    JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
  AND ons.areas ->> 'pcon18cd' = 'E14001011'
  AND (nullif(ad.document ->> 'valid_until', '')::date > now())
GROUP BY  ad.document ->> 'assessment_type';

--avg EIR

SELECT  ad.document ->> 'assessment_type' as assessment_type, AVG((ad.document ->> 'environmental_impact_current')::int),
    ad.document ->> 'assessment_type' as assessment_type
FROM assessment_documents ad
    JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
  and   ad.document ->> 'postcode' NOT LIKE 'BT%'
  AND (nullif(document->>'registration_date', '')::date) > ('2021-04-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-03-31 00:00':: timestamp)
  AND ons.areas ->> 'pcon18cd' = 'E14001011'
GROUP BY  ad.document ->> 'assessment_type'
    [2022-04-14 10:46:36] 2 rows retrieved starting from 1 in 5 m 59 s 453 ms (execution: 5 m 59 s 400 ms, fetching: 53 ms)

-- totals by month year


--EER national avg
SELECT  ad.document ->> 'assessment_type' as assessment_type, AVG((ad.document ->> 'energy_rating_current')::int),
    ad.document ->> 'assessment_type' as assessment_type
FROM assessment_documents ad
    --JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
  and   ad.document ->> 'postcode' NOT LIKE 'BT%'
  AND (nullif(document->>'registration_date', '')::date) > ('2021-04-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-03-31 00:00':: timestamp)
--AND ons.areas ->> 'pcon18cd' = 'E14001011'
GROUP BY  ad.document ->> 'assessment_type';

--Walsall RdSAP breakdown of construction age
SELECT num_epcs,
       ( SELECT REPLACE((string_to_array(lookup_value, ';'))[1], 'England and Wales: ', '')
         FROM assessment_attribute_lookups aal
                  JOIN assessment_lookups al on aal.lookup_id = al.id
         WHERE schema_version = 'RdSAP-Schema-20.0.0' and attribute_id = 6 AND al.lookup_key = construction_age_band LIMIT 1) as construction_age

FROM  (
    SELECT  count(*) as num_epcs,
    (jsonb_array_elements(ad.document -> ('sap_building_parts')) ->> 'construction_age_band')::varchar as construction_age_band
    FROM assessment_documents ad
    JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
    WHERE ad.document ->> 'assessment_type' IN ('RdSAP')
    AND (nullif(document->>'registration_date', '')::date) > ('2021-04-01 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-03-31 00:00':: timestamp)
    AND ons.areas ->> 'pcon18cd' = 'E14001011'
    GROUP BY  jsonb_array_elements(ad.document -> ('sap_building_parts')) ->> 'construction_age_band') as c


