--- Query for property types
select property_type, round(avg(u_value)::numeric, 4) from (
select
    SUM(u_value * total_wall_area) / SUM(total_wall_area) as u_value,
    al.lookup_value as property_type
from (
select assessment_id,
       u_value,
       total_wall_area,
       ad.document ->> 'property_type' as property_code
from
    assessment_documents ad,
    jsonb_to_recordset(ad.document -> 'sap_building_parts' -> 0 -> 'sap_walls') as wall(name text, u_value float, total_wall_area float)
    where (ad.document->>'registration_date' between '2022-10-01' and '2023-09-30')
    AND (ad.document ->> 'schema_type')::varchar IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')
    AND (ad.document ->> 'data_type' != '4')
    and (ad.document -> 'sap_building_parts') is not null
    and name like 'Walls%') as sample
join assessment_lookups al on al.lookup_key = property_code
join assessment_attribute_lookups aal on aal.lookup_id = al.id
and aal.attribute_id = 8
and aal.schema_version ='RdSAP-Schema-19.0'
group by assessment_id, al.lookup_value) as u_value_query
group by property_type;


-- Query for all averages
select round(avg(u_value)::numeric, 4) from (
select
    SUM(u_value * total_wall_area) / SUM(total_wall_area) as u_value
from (
select assessment_id,
       u_value,
       total_wall_area
from
    assessment_documents ad,
    jsonb_to_recordset(ad.document -> 'sap_building_parts' -> 0 -> 'sap_walls') as wall(name text, u_value float, total_wall_area float)
    where (ad.document->>'registration_date' between '2022-10-01' and '2023-09-30')
    AND (ad.document ->> 'schema_type')::varchar IN ('SAP-Schema-19.0.0', 'SAP-Schema-19.1.0')
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')
    AND (ad.document ->> 'data_type' != '4')
    and (ad.document -> 'sap_building_parts') is not null
    and name like 'Walls%') as sample
group by assessment_id) as u_value_query;