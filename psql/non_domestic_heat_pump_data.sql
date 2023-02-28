SELECT
    assessment_id as assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    hvac_systems ->> 'heat_source' as heat_source,
    hvac_systems ->> 'heating_sseff' as heating_sseff,
    hvac_systems ->> 'heating_gen_seff' as heating_gen_seff,
    hvac_systems ->> 'area' as heat_pump_area,
    ad.document -> 'technical_information' ->> 'floor_area' as total_floor_area,
    building_parts ->> 'analysis_type' as analysis_type
FROM assessment_documents ad,
    jsonb_array_elements(ad.document -> 'summary_of_performance' -> 'building_data') building_parts,
    jsonb_array_elements(building_parts -> 'hvac_systems') hvac_systems
WHERE building_parts  ->> 'analysis_type' = 'ACTUAL'
  AND hvac_systems ->> 'heat_source' LIKE 'Heat pump%'
  AND ad.document ->> 'postcode' NOT LIKE 'BT%'
  AND (ad.document ->> 'transaction_type' = '3')
  AND (ad.document ->> 'assessment_type')::varchar = 'CEPC'
  AND (nullif(ad.document->>'registration_date', '')::date) > ('2023-02-01 00:00':: timestamp) AND (nullif(ad.document->>'registration_date', '')::date) < ('2023-02-28 00:00':: timestamp);