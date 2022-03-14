-- export query to find new dwelling with heat pumps
SELECT COUNT(DISTINCT aav.assessment_id), To_DATE(d.registered_date, 'yyyy-mm') as registered_date
FROM assessment_attribute_values aav
         JOIN (SELECT aav1.assessment_id, attribute_value_int
               FROM assessment_attribute_values aav1 WHERE attribute_id = 10) as t
              ON t.assessment_id = aav.assessment_id
         JOIN (SELECT aav2.assessment_id, aav2.json
               FROM assessment_attribute_values aav2
               WHERE aav2.attribute_id = 86 ) as h
              ON h.assessment_id = aav.assessment_id
         JOIN (SELECT aav3.assessment_id, aav3.attribute_value as registered_date
               FROM assessment_attribute_values aav3
               WHERE aav3.attribute_id = 22)  as d
              ON d.assessment_id = aav.assessment_id
WHERE To_DATE(d.registered_date, 'yyyy-mm-dd') BETWEEN '2020-10-01' AND '2022-01-28'
  AND t.attribute_value_int = 6
  AND h.json::text LIKE '%Ground source heat pump%' OR h.json::text LIKE '%Air source heat pump%'
GROUP BY To_DATE(d.registered_date, 'yyyy-mm');