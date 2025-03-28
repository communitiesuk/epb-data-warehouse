-- for newer assessments (updated Mar 2025)

select
ado.assessment_id as assessment_id,
ado.document ->> 'hashed_assessment_id' hashed_assessment_id,
ado.document ->> 'schema_type' schema_type,
ado.document ->> 'registration_date' as registration_date,
ado.document ->> 'country_code' as country_code,
u_value,
ado.document ->> 'transaction_type' transaction_type,
ado.document ->'sap_ventilation'-> 'pressure_test' pressure_test_code,
ado.document -> 'sap_ventilation' -> 'air_permeability' air_permeability,
ado.document -> 'sap_building_parts'-> 0 -> 'sap_thermal_bridges' -> 'thermal_bridge_code' thermal_bridge_code
from (
select
assessment_id as assessment_id,
(SUM(u_value * total_wall_area) / SUM(total_wall_area) ) as u_value
from (
select assessment_id,
u_value,
total_wall_area
from
assessment_documents ad,
jsonb_to_recordset(ad.document -> 'sap_building_parts' -> 0 -> 'sap_walls') as wall(wall_type int, u_value float, total_wall_area float)
where ad.document->>'registration_date' between '2025-01-01' and '2025-01-31'
AND (ad.document ->> 'schema_type')::varchar IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
and wall_type in (2)
)
as u_value_query
group by assessment_id) as sample
inner join assessment_documents ado on sample.assessment_id = ado.assessment_id
where ado.document ->> 'country_code' IN ('ENG', 'WLS', 'EAW');

-- for older assessments

select
ado.assessment_id as assessment_id,
ado.document ->> 'hashed_assessment_id' hashed_assessment_id,
c.country_name as country_name,
ado.document ->> 'schema_type' schema_type,
u_value,
ado.document ->> 'transaction_type' transaction_type,
ado.document ->'sap_ventilation'-> 'pressure_test' pressure_test_code,
ado.document -> 'sap_ventilation' -> 'air_permeability' air_permeability,
ado.document -> 'sap_building_parts'-> 0 -> 'sap_thermal_bridges' -> 'thermal_bridge_code' thermal_bridge_code
from (
select
assessment_id as assessment_id,
(SUM(u_value * total_wall_area) / SUM(total_wall_area) ) as u_value
from (
select assessment_id,
u_value,
total_wall_area
from
assessment_documents ad,
jsonb_to_recordset(ad.document -> 'sap_building_parts' -> 0 -> 'sap_walls') as wall(wall_type int, u_value float, total_wall_area float)
where ad.document->>'registration_date' > '2022-12-31'
AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
AND (ad.document ->> 'schema_type')::varchar NOT IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
and wall_type in (2)
)
as u_value_query
group by assessment_id) as sample
inner join assessment_documents ado on sample.assessment_id = ado.assessment_id
join assessments_country_ids aci on sample.assessment_id = aci.assessment_id
join countries c on c.country_id = aci.country_id
where aci.country_id in (1, 2, 4);

