--- Count of SAP heat pump properties
Select registration_month, count(distinct assessment_id)
from (
    select assessment_id as assessment_id,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description,
       extract(month from (ad.document->>'registration_date')::date) as registration_month
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2017-01-01' AND '2017-12-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')) as SAP
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by registration_month;

--- Count of heat pump properties by property type
select
        CASE WHEN property_type = '0' THEN 'House'
            WHEN property_type  = '1' THEN 'Bungalow'
            WHEN property_type = '2' THEN 'Flat'
           WHEN property_type = '3' THEN 'Maisonette'
           WHEN property_type = '4' THEN 'Park home'
        END as property_type,
    count(distinct (assessment_id))
from (
select assessment_id as assessment_id,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description,
       ad.document ->> 'property_type' as property_type
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2018-01-01' AND '2018-12-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')) as Prop_SAP
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by
    CASE WHEN property_type = '0' THEN 'House'
            WHEN property_type  = '1'  THEN 'Bungalow'
            WHEN property_type = '2' THEN 'Flat'
           WHEN property_type = '3' THEN 'Maisonette'
           WHEN property_type = '4' THEN 'Park home'
        END;

--- Count of heat pump properties by floor type

select total_floor_area,
    sum(case when year = 2016 then number_of_assessments else 0 end) as year_2016,
    sum(case when year = 2017 then number_of_assessments else 0 end) as year_2017,
    sum(case when year = 2018 then number_of_assessments else 0 end) as year_2018,
    sum(case when year = 2019 then number_of_assessments else 0 end) as year_2019,
    sum(case when year = 2020 then number_of_assessments else 0 end) as year_2020,
    sum(case when year = 2021 then number_of_assessments else 0 end) as year_2021,
    sum(case when year = 2022 then number_of_assessments else 0 end) as year_2022,
    sum(case when year = 2023 then number_of_assessments else 0 end) as year_2023_
from
(select year,
        CASE WHEN total_floor_area::numeric BETWEEN 0 AND 50 THEN 'BETWEEN 0 AND 5O'
         WHEN total_floor_area::numeric BETWEEN 51 AND 100 THEN 'BETWEEN 51 AND 100'
         WHEN total_floor_area::numeric BETWEEN 101 AND 150 THEN 'BETWEEN 101 AND 150'
         WHEN total_floor_area::numeric BETWEEN 151 AND 200 THEN 'BETWEEN 151 AND 200'
        WHEN total_floor_area::numeric BETWEEN 201 AND 250 THEN 'BETWEEN 200 AND 250'
         WHEN total_floor_area::numeric >= 251 THEN 'GREATER THAN 251'
        END as total_floor_area,
    count(distinct (assessment_id)) as number_of_assessments
from (
select assessment_id as assessment_id,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description,
       extract(year from (ad.document->>'registration_date')::date) as year,
       ad.document ->> 'total_floor_area' as total_floor_area
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2012-01-01' AND '2023-08-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%') as Prop_SAP
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by year,
    CASE WHEN total_floor_area::numeric BETWEEN 0 AND 50 THEN 'BETWEEN 0 AND 5O'
         WHEN total_floor_area::numeric BETWEEN 51 AND 100 THEN 'BETWEEN 51 AND 100'
         WHEN total_floor_area::numeric BETWEEN 101 AND 150 THEN 'BETWEEN 101 AND 150'
         WHEN total_floor_area::numeric BETWEEN 151 AND 200 THEN 'BETWEEN 151 AND 200'
        WHEN total_floor_area::numeric BETWEEN 201 AND 250 THEN 'BETWEEN 200 AND 250'
         WHEN total_floor_area::numeric >= 251 THEN 'GREATER THAN 251'
        END) as result
group by total_floor_area;

--- Count of heat pump properties by local authority
select
    local_authority,
    sum(case when year = 2016 then number_of_assessments else 0 end) as year_2016,
    sum(case when year = 2017 then number_of_assessments else 0 end) as year_2017,
    sum(case when year = 2018 then number_of_assessments else 0 end) as year_2018,
    sum(case when year = 2019 then number_of_assessments else 0 end) as year_2019,
    sum(case when year = 2020 then number_of_assessments else 0 end) as year_2020,
    sum(case when year = 2021 then number_of_assessments else 0 end) as year_2021,
    sum(case when year = 2022 then number_of_assessments else 0 end) as year_2022,
    sum(case when year = 2023 then number_of_assessments else 0 end) as year_2023_
from (
select
    name as local_authority,
    year,
    count(distinct assessment_id) as number_of_assessments
from (
select assessment_id as assessment_id,
       ad.document ->> 'postcode' as postcode,
       extract(year from (ad.document->>'registration_date')::date) as year,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2016-01-01' AND '2023-08-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')
    )as Prop_SAP
left join ons_postcode_directory ons on Prop_SAP.postcode = ons.postcode
left join ons_postcode_directory_names onsn on ons.local_authority_code = onsn.area_code
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by name, year) as Result
group by Result.local_authority;

--- Count of heat pump properties by westminster parliamentary constituency
select
    westminster_parliamentary_constituency,
    sum(case when year = 2016 then number_of_assessments else 0 end) as year_2016,
    sum(case when year = 2017 then number_of_assessments else 0 end) as year_2017,
    sum(case when year = 2018 then number_of_assessments else 0 end) as year_2018,
    sum(case when year = 2019 then number_of_assessments else 0 end) as year_2019,
    sum(case when year = 2020 then number_of_assessments else 0 end) as year_2020,
    sum(case when year = 2021 then number_of_assessments else 0 end) as year_2021,
    sum(case when year = 2022 then number_of_assessments else 0 end) as year_2022,
    sum(case when year = 2023 then number_of_assessments else 0 end) as year_2023_
from (
select
    name as westminster_parliamentary_constituency,
    year,
    count(distinct assessment_id) as number_of_assessments
from (
select assessment_id as assessment_id,
       ad.document ->> 'postcode' as postcode,
       extract(year from (ad.document->>'registration_date')::date) as year,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2016-01-01' AND '2023-08-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')
    )as Prop_SAP
left join ons_postcode_directory ons on Prop_SAP.postcode = ons.postcode
left join ons_postcode_directory_names onsn on ons.westminster_parliamentary_constituency_code = onsn.area_code
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by name, year) as Result
group by Result.westminster_parliamentary_constituency;

--- heat pump properties by descriptions (grouped)
select
        CASE
            WHEN main_heating_description ILIKE '%Mixed exhaust air source heat pump%' THEN 'Mixed exhaust air source heat pump'
            WHEN main_heating_description ILIKE '%Exhaust air MEV source heat pump%' THEN 'Exhaust air MEV source heat pump'
            WHEN main_heating_description ILIKE '%Ground source heat pump%' THEN 'Ground source heat pump'
            WHEN main_heating_description ILIKE '%Water source heat pump%' THEN 'Water source heat pump'
            WHEN main_heating_description  ILIKE '%Air source heat pump%' THEN 'Air source heat pump'
            else main_heating_description
        END as main_heating_description,
    count(distinct assessment_id)
from (
select assessment_id as assessment_id,
       (jsonb_array_elements(ad.document -> ('main_heating')) ->> 'description')::varchar as main_heating_description
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2023-01-01' AND '2023-09-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')) as Prop_SAP
where ( main_heating_description ILIKE '%heat pump%' or main_heating_description ILIKE '%pwmp gwres%')
group by
    CASE
        WHEN main_heating_description ILIKE '%Mixed exhaust air source heat pump%' THEN 'Mixed exhaust air source heat pump'
        WHEN main_heating_description ILIKE '%Exhaust air MEV source heat pump%' THEN 'Exhaust air MEV source heat pump'
        WHEN main_heating_description ILIKE '%Ground source heat pump%' THEN 'Ground source heat pump'
        WHEN main_heating_description ILIKE '%Water source heat pump%' THEN 'Water source heat pump'
        WHEN main_heating_description  ILIKE '%Air source heat pump%' THEN 'Air source heat pump'
        else main_heating_description
    END;

