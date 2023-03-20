--export for domestic EPCS
SELECT assessment_id,
        items.sequence as IMPROVEMENT_ITEM,
        items.improvement_category as IMPROVEMENT_ID,
        items.indicative_cost as INDICATIVE_COST
FROM assessment_documents ad,
     json_to_recordset((ad.document -> 'suggested_improvements')::json) AS
         items(sequence integer, indicative_cost varchar, improvement_type varchar,improvement_category varchar )

WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
AND (nullif(document->>'registration_date', '')::date)  > '2022-03-01 00:00'
AND (nullif(document->>'registration_date', '')::date)  < '2023-03-01 00:00'
and   ad.document ->> 'postcode' LIKE 'BT%';

--export for non-domestic CEPC-RR
SELECT ad.document,
       items.co2_impact as CO2_IMPACT,
        items.recommendation as RECOMMENDATION,
        items.recommendation_code as RECOMMENDATION_CODE,
        'long' as PAYBACK_TYPE
FROM assessment_documents ad,
  json_to_recordset((ad.document -> 'long_payback')::json) AS
         items(recommendation_code varchar, recommendation varchar, co2_impact varchar )
WHERE ad.document ->> 'assessment_type' = 'CEPC-RR'
AND (nullif(document->>'registration_date', '')::date)  > '2022-03-01 00:00'
AND (nullif(document->>'registration_date', '')::date)  < '2023-03-01 00:00'
and   ad.document ->> 'postcode' LIKE 'BT%'
UNION
SELECT ad.document,
       items.co2_impact as CO2_IMPACT,
        items.recommendation as RECOMMENDATION,
        items.recommendation_code as RECOMMENDATION_CODE,
        'medium' as PAYBACK_TYPE
FROM assessment_documents ad,
  json_to_recordset((ad.document -> 'medium_payback')::json) AS
         items(recommendation_code varchar, recommendation varchar, co2_impact varchar )
WHERE ad.document ->> 'assessment_type' = 'CEPC-RR'
AND (nullif(document->>'registration_date', '')::date)  > '2022-03-01 00:00'
AND (nullif(document->>'registration_date', '')::date)  < '2023-03-01 00:00'
and   ad.document ->> 'postcode' LIKE 'BT%'
UNION
SELECT ad.document,
       items.co2_impact as CO2_IMPACT,
        items.recommendation as RECOMMENDATION,
        items.recommendation_code as RECOMMENDATION_CODE,
        'short' as PAYBACK_TYPE
FROM assessment_documents ad,
  json_to_recordset((ad.document -> 'short_payback')::json) AS
         items(recommendation_code varchar, recommendation varchar, co2_impact varchar )
WHERE ad.document ->> 'assessment_type' = 'CEPC-RR'
AND (nullif(document->>'registration_date', '')::date)  > '2022-03-01 00:00'
AND (nullif(document->>'registration_date', '')::date)  < '2023-03-01 00:00'
and   ad.document ->> 'postcode' LIKE 'BT%';