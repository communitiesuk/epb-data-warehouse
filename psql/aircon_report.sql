SELECT
    (document ->> 'building_name') as building_name,
    (document ->> 'address_line_1') as address_line_1,
    (document ->> 'address_line_2') as address_line_2,
    (document ->> 'address_line_3') as address_line_3,
    (document ->> 'address_line_4') as address_line_4,
    (document ->> 'postcode') as postcode,
    (document ->> 'post_town') as post_town,
    (document ->> 'registration_date') as registration_date,
    (document ->> 'valid_until') as valid_until,
    (document ->> 'treated_floor_area') as treated_floor_area,
    (document ->> 'building_complexity') as building_complexity,
    (document -> 'ac_rated_output' ->> 'ac_kw_rating') as ac_kw_rating
FROM assessment_documents ad
         JOIN assessments_country_ids aci ON ad.assessment_id = aci.assessment_id
         JOIN countries c ON c.country_id = aci.country_id
WHERE c.country_code IN ('ENG', 'EAW', 'WLS')
  AND document ->> 'report_type' = '6'
  AND document -> 'opt_out' IS NULL
  AND document ->> 'created_at' >= '2024-06-01';