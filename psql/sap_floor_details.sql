Select
    assessment_id,
    hashed_assessment_id,
    registration_date,
    country,
    sap_floor_dimensions ->> 'name' as name,
    sap_floor_dimensions ->> 'description' as description,
    sap_floor_dimensions ->> 'storey' as storey,
    sap_floor_dimensions ->> 'u_value' as u_value,
    sap_floor_dimensions ->> 'floor_type' as floor_type,
    sap_floor_dimensions ->> 'kappa_value' as kappa_value,
    sap_floor_dimensions ->> 'storey_height' as storey_height,
    sap_floor_dimensions ->> 'heat_loss_area' as heat_loss_area,
    sap_floor_dimensions ->> 'total_floor_area' as total_floor_area,
    sap_floor_dimensions ->> 'kappa_value_from_below' as kappa_value_from_below
    from
(SELECT
    ad.assessment_id as assessment_id,
    ad.document ->> 'hashed_assessment_id' as hashed_assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    (sap_building_parts)::jsonb as sap_building_parts,
    c.country_name as country
FROM assessment_documents ad
    join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
    join countries c on c.country_id = aci.country_id,
    jsonb_array_elements(ad.document -> 'sap_building_parts') sap_building_parts
WHERE document ->> 'schema_type' IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
  AND aci.country_id in (1, 4)) as SAP_building,
    jsonb_array_elements(sap_building_parts -> 'sap_floor_dimensions') sap_floor_dimensions;