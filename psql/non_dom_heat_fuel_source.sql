SELECT
ad.document ->> 'hashed_assessment_id' as hashed_assessment_id,
ad.document ->> 'registration_date' as registration_date,
ad.document ->> 'property_type' as property_type,
hvac_systems ->> 'heat_source' as heat_source,
hvac_systems ->> 'fuel_type' as fuel_type,
hvac_systems ->> 'heating_sseff' as heating_sseff,
hvac_systems ->> 'heating_gen_seff' as heating_gen_seff,
hvac_systems ->> 'area' as heating_area,
ad.document -> 'technical_information' ->> 'floor_area' as total_floor_area,
building_parts -> 'global_performance' -> 'kwh_m2_pvs' as kwh_m2_pvs
FROM assessment_documents ad,
jsonb_array_elements(ad.document -> 'summary_of_performance' -> 'building_data') building_parts,
jsonb_array_elements(building_parts -> 'hvac_systems') hvac_systems
WHERE building_parts ->> 'analysis_type' IN ('ACTUAL')
AND ad.document ->> 'postcode' NOT LIKE 'BT%'
AND (ad.document ->> 'transaction_type' = '3')
AND (ad.document ->> 'assessment_type')::varchar = 'CEPC'
AND ad.document -> 'opt_out' IS NULL
AND (ad.document->>'registration_date' BETWEEN '2023-01-01' AND '2023-12-31');