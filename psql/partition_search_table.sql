-- CREATE UDF TO DEAL WITH VIEWS DEPENDENT ON THE TABLE BEING REPLACED
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION replace_view_table(view_schema text, view_name text, old_table text, new_table text) RETURNS void AS $$
DECLARE
view_definition text;
BEGIN
SELECT definition INTO view_definition
FROM pg_views
WHERE schemaname = view_schema
  AND viewname = view_name;

view_definition := REPLACE(view_definition, old_table, new_table);

EXECUTE 'CREATE OR REPLACE VIEW ' || view_schema || '.' || view_name || ' AS ' || view_definition;
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- CREATE UDF TO DEAL WITH MVIEWS DEPENDENT ON THE TABLE BEING REPLACED
------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION replace_mview_table(view_schema text, view_name text, old_table text, new_table text) RETURNS void AS $$
DECLARE
view_definition text;
BEGIN
SELECT definition INTO view_definition
FROM pg_matviews
WHERE schemaname = view_schema
  AND matviewname = view_name;

view_definition := REPLACE(view_definition, old_table, new_table);
EXECUTE 'DROP MATERIALIZED VIEW ' || view_schema || '.' || view_name;
EXECUTE 'CREATE MATERIALIZED VIEW ' || view_schema || '.' || view_name || ' AS ' || replace(view_definition, ';', '') || ' WITH NO DATA ';
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------
-- CREATE TEMP TABLE WITH PARTITION BY DATE
------------------------------------------------------------------------

create table assessment_search_temp
(
    assessment_id                    varchar,
    address_line_1                   varchar,
    address_line_2                   varchar,
    address_line_3                   varchar,
    address_line_4                   varchar,
    post_town                        varchar(100),
    postcode                         varchar(10),
    current_energy_efficiency_rating integer,
    current_energy_efficiency_band   varchar(2),
    council                          varchar(40),
    constituency                     varchar(45),
    assessment_address_id            varchar(30),
    address                          varchar(500),
    registration_date                timestamp with time zone,
    assessment_type                  varchar(8),
    created_at                       timestamp
)
    PARTITION BY RANGE (registration_date);

------------------------------------------------------------------------
-- EXEC FUNCTION TO GENERATE PARTITIONS ON TEMP TABLE
------------------------------------------------------------------------
SELECT fn_create_day_month_partition('assessment_search_temp', 2025);

------------------------------------------------------------------------
-- INSERT DATA FROM ASSESSMENT_SEARCH INTO TEMP TABLE
------------------------------------------------------------------------

INSERT INTO assessment_search_temp(assessment_id, address_line_1, address_line_2, address_line_3, address_line_4, post_town, postcode, current_energy_efficiency_rating,
                                   current_energy_efficiency_band, council,
                                   constituency, assessment_address_id, address,
                                   registration_date, assessment_type, created_at)
SELECT  assessment_id, address_line_1, address_line_2, address_line_3, address_line_4, post_town, postcode, current_energy_efficiency_rating,
        current_energy_efficiency_band, council,
        constituency, assessment_address_id, address,
        registration_date, assessment_type, created_at
FROM assessment_search


------------------------------------------------------------------------
-- TRANSACTION BLOCK TO REPLACE VIEWS AND MVIEWS, DROP TABLE AND SWITCH TEMP TABLE NAME TO ASSESSMENT_SEARCH
------------------------------------------------------------------------
BEGIN;
SELECT replace_view_table('public', 'vw_domestic_documents_2012', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2013', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2014', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2015', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2016', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2017', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2018', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2019', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2020', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2021', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2022', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2023', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2024', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_documents_2025', 'assessment_search', 'assessment_search_temp');
SELECT replace_view_table('public', 'vw_domestic_yesterday', 'assessment_search', 'assessment_search_temp');
SELECT replace_mview_table('public', 'mvw_domestic_search', 'assessment_search', 'assessment_search_temp');

DROP TABLE assessment_search;
ALTER TABLE assessment_search_temp RENAME TO assessment_search;
COMMIT;

------------------------------------------------------------------------
-- RECREATE INDEXES ON ASSESSMENT_SEARCH
------------------------------------------------------------------------

BEGIN;

create unique index assessment_search_pkey
    on assessment_search (assessment_id, registration_date);

create index index_assessment_search_on_postcode
    on assessment_search (postcode);

create index index_assessment_search_on_current_energy_efficiency_band
    on assessment_search (current_energy_efficiency_band);

create index index_assessment_search_on_council
    on assessment_search (council);

create index index_assessment_search_on_constituency
    on assessment_search (constituency);

create index index_assessment_search_on_assessment_address_id
    on assessment_search (assessment_address_id);


create index index_assessment_search_on_assessment_type
    on assessment_search (assessment_type);

create index index_assessment_search_on_created_at
    on assessment_search (created_at);

create index index_assessment_search_on_address_trigram
    on assessment_search using gin (address gin_trgm_ops);
COMMIT;