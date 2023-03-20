
SELECT asset_rating, numEpcs,
       CASE WHEN regions = 'E12000001' THEN 'North East'
            WHEN regions = 'E12000002' THEN 'North West'
            WHEN regions = 'E12000003' THEN 'Yorkshire and The Humber'
            WHEN regions = 'E12000004' THEN 'East Midlands'
            WHEN regions = 'E12000005' THEN 'West Midlands'
            WHEN regions = 'E12000006' THEN 'East of England'
            WHEN regions = 'E12000007' THEN 'London'
            WHEN regions = 'E12000008' THEN 'South East'
            WHEN regions = 'E12000009' THEN 'South West'
            WHEN regions = 'W99999999' THEN 'Wales'
            WHEN regions = 'N99999999' THEN 'Northern Ireland'
            WHEN regions = 'L99999999' THEN 'Channel Islands'
            WHEN regions = 'M99999999' THEN 'Isle of Man'
END as regions
FROM (
SELECT ad.document ->> 'asset_rating' asset_rating, count(*) as numEpcs, ons.areas ->> 'rgn21cd' as regions
FROM assessment_documents ad
LEFT JOIN assessment_lookups al ON al.lookup_key = ad.document ->> 'transaction_type'
LEFT JOIN assessment_attribute_lookups aal on aal.lookup_id = al.id
JOIN ons_uprn_directory ons ON ad.document ->> 'postcode' = ons.postcode
WHERE ad.document ->> 'assessment_type' = 'CEPC'
AND (nullif(document->>'registration_date', '')::date)  > '2022-03-01 00:00'
AND (nullif(document->>'registration_date', '')::date)  < '2023-03-01 00:00'
AND ad.document ->> 'property_type' = 'Restaurants and Cafes/Drinking Establishments/Takeaways'
AND lookup_value =  'Mandatory issue (Property to let).'
group by ad.document ->> 'asset_rating', ons.areas ->> 'rgn21cd') as A;





