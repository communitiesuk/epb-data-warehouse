SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


--
-- Name: energy_band_calculator(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.energy_band_calculator(energy_rating_current integer, assessment_type character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
energy_band varchar;

BEGIN
IF lower(assessment_type) LIKE '%sap'
    THEN
       IF energy_rating_current  <= 20 THEN  energy_band ='G';
        ELSEIF energy_rating_current BETWEEN 21 AND 38 THEN  energy_band ='F';
        ELSEIF energy_rating_current  BETWEEN 39 AND 54  THEN energy_band ='E';
        ELSEIF energy_rating_current BETWEEN 55 AND 68 THEN energy_band ='D';
        ELSEIF energy_rating_current BETWEEN 69 AND 80 THEN  energy_band ='C';
        ELSEIF energy_rating_current BETWEEN 81 AND 91 THEN  energy_band ='B';
        ELSE  energy_band = 'A';
    END IF;
ELSE
       IF energy_rating_current  <= -1 THEN  energy_band ='A+';
        ELSEIF energy_rating_current BETWEEN 0 AND 25 THEN  energy_band ='A';
        ELSEIF energy_rating_current  BETWEEN 26 AND 50  THEN energy_band ='B';
        ELSEIF energy_rating_current BETWEEN 51 AND 75 THEN energy_band ='C';
        ELSEIF energy_rating_current BETWEEN 76 AND 100 THEN  energy_band ='D';
        ELSEIF energy_rating_current BETWEEN 101 AND 125 THEN  energy_band ='E';
        ELSEIF energy_rating_current BETWEEN 126 AND 150 THEN  energy_band ='F';
        ELSE energy_band = 'G';
    END IF;
 END IF;


RETURN energy_band;

END $$;


--
-- Name: fn_clean_description(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_clean_description(description character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
            DECLARE
            data varchar;

            BEGIN

             PERFORM description::jsonb;
                  return (description)::jsonb ->> 'value';
            EXCEPTION WHEN others THEN
                return regexp_replace(description::varchar, '{.*', '', 'g');
            END

$$;


--
-- Name: fn_construction_age_band(jsonb, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_construction_age_band(document jsonb, assessment_type character varying, version character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
                 DECLARE
                 construction_age varchar;
                 construction_age_band varchar;
                 construction_year varchar;

                 BEGIN
                     construction_age := COALESCE(document -> 'sap_building_parts' -> 0 ->> 'construction_age_band',  document -> 'sap_building_parts' -> 1 ->> 'construction_age_band');
                     construction_year :=  COALESCE(document -> 'sap_building_parts' -> 0 ->> 'construction_year',  document -> 'sap_building_parts' -> 1 ->> 'construction_year');
                     IF construction_age IS NOT NULL THEN
                            construction_age_band := public.get_lookup_value('construction_age_band', construction_age, assessment_type, version);
                       ELSEIF construction_year IS NOT NULL THEN
                           construction_age_band := construction_year;
                      END IF;

                       return construction_age_band;
                 END

     $$;


--
-- Name: fn_create_day_month_partition(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_create_day_month_partition(table_name text, end_year integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
     DECLARE
          partition_name varchar;
          start_date varchar;
          end_date varchar;
          sql text;



BEGIN


   FOR y IN 2012..end_year LOOP
       FOR m IN 1..12 LOOP
           start_date = make_date(y, m, 1)::varchar;
            IF m < 12 THEN
                end_date =  make_date(y, m+1, 1)::varchar ;
            ELSE
                end_date =  make_date(y+1, 1, 1)::varchar;
            END IF;
               partition_name = table_name || concat('_y', y, 'm', m);
             sql='CREATE TABLE IF NOT EXISTS ' || partition_name || ' PARTITION OF '|| table_name ||' FOR VALUES FROM (' || quote_literal(start_date) || ') TO  (' || quote_literal(end_date) ||')';
             EXECUTE sql;
         END LOOP;
   END LOOP;
END
$$;


--
-- Name: fn_export_json_document(jsonb, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_export_json_document(document jsonb, matched_uprn bigint) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
      DECLARE
       data jsonb;
       address_id text;
       uprn varchar(20);
       uprn_source varchar(20);
       energy_band varchar(2);
       assessment_type varchar(7);
       potential_energy_band varchar(2);

    BEGIN

       address_id := REPLACE((document ->> 'assessment_address_id')::text,   'UPRN-', '');
       assessment_type  :=  (document->> 'assessment_type')::varchar;

      data := document
        - 'scheme_assessor_id'::text
        - 'equipment_owner'::text
        - 'equipment_operator'::text
        - 'owner'::text
        - 'occupier'::text
        - 'assessment_address_id'::text
        - 'calculation_software_name'::text
        - 'opt_out'::text
        - 'hashed_assessment_id'::text
        - 'cancelled_at'::text
        - 'related_rrn'::text
        - 'matched_uprn'::text;

      IF document ? 'related_rrn' THEN
          data := data || jsonb_build_object('related_certificate_number', document -> 'related_rrn');
      END IF;

      IF assessment_type = 'CEPC' THEN
          energy_band := energy_band_calculator((document ->> 'asset_rating')::int,  assessment_type);
       ELSIF assessment_type = 'DEC' THEN
          energy_band := energy_band_calculator((document -> 'this_assessment' ->> 'energy_rating')::int,  assessment_type);
       ELSIF assessment_type LIKE '%RR%' THEN
          energy_band := null;
      ELSE
           energy_band := energy_band_calculator((document ->> 'energy_rating_current')::int,  assessment_type);
           potential_energy_band := energy_band_calculator((document ->> 'energy_rating_potential')::int,  assessment_type);
      END IF;

      if energy_band IS NOT NULL THEN
        data := jsonb_set(data, '{current_energy_efficiency_band}', to_jsonb((energy_band)::varchar), true);
       END IF;

      if potential_energy_band IS NOT NULL THEN
        data := jsonb_set(data, '{potential_energy_efficiency_band}', to_jsonb((potential_energy_band)::varchar), true);
       END IF;

      IF address_id ~ '^[0-9]+$' THEN
          uprn := address_id;
          uprn_source := 'Energy Assessor';
      ELSIF matched_uprn IS NOT NULL THEN
          uprn := matched_uprn::text;
          uprn_source := 'Address Matched';
      ELSE
          uprn := NULL;
          uprn_source := '';
      END IF;

      IF uprn IS NULL THEN
          address_id := '';
          data := jsonb_set(data, '{uprn}', 'null'::jsonb, true);
      ELSE
          data := jsonb_set(data, '{uprn}', to_jsonb((uprn)::bigint), true);
      END IF;

      data := jsonb_set(data, '{uprn_source}', to_jsonb(uprn_source), true);

      return data;
    END
    $_$;


--
-- Name: fn_uprn_source(character varying, bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_uprn_source(assessment_address_id character varying, matched_uprn bigint) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE

uprn_source varchar;

BEGIN
    IF starts_with(assessment_address_id, 'UPRN') THEN
        uprn_source = 'Energy Assessor';
    ELSEIF starts_with(assessment_address_id, 'RRN') and matched_uprn IS NOT NULL THEN
        uprn_source = 'Address Matched';
    END if;
RETURN uprn_source;

END $$;


--
-- Name: get_attribute_json(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_attribute_json(attribute character varying, rrn character varying) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
    DECLARE
    data jsonb;
    BEGIN

      SELECT DISTINCT json INTO data
      FROM public.assessment_attribute_values aav
      JOIN public.assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN data;

      END $$;


--
-- Name: get_attribute_value(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_attribute_value(attribute character varying, rrn character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE
    value varchar;
    BEGIN

      SELECT DISTINCT attribute_value INTO value
      FROM public.assessment_attribute_values aav
      JOIN public.assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN value;

      END $$;


--
-- Name: get_lookup_value(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_lookup_value(attribute character varying, key character varying, assessmennt_type character varying, version character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
value varchar;
BEGIN


    SELECT DISTINCT lookup_value INTO value
    FROM public.assessment_attribute_lookups aal
    JOIN public.assessment_lookups al on aal.lookup_id = al.id
    JOIN public.assessment_attributes aa on aal.attribute_id = aa.attribute_id
    WHERE  aa.attribute_name = attribute AND al.lookup_key = key AND aal.type_of_assessment =assessmennt_type and schema_version LIKE  (version || '%');

 RETURN value;

END $$;


--
-- Name: sum_attribute_values(character varying[], character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sum_attribute_values(attribute_names character varying[], assessment_id character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
      DECLARE
        attribute_name VARCHAR;
        total_value NUMERIC := 0;
        attribute_was_present BOOLEAN := FALSE;
        current_value NUMERIC;
      BEGIN
        FOREACH attribute_name IN ARRAY attribute_names LOOP
          current_value := public.get_attribute_value(attribute_name, assessment_id)::numeric;

          IF current_value IS NOT NULL THEN
              total_value := total_value + current_value;
              attribute_was_present := TRUE;
          END IF;
        END LOOP;

        IF NOT attribute_was_present THEN
          RETURN NULL;
        ELSE
          RETURN total_value;
        END IF;
      END $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assessment_attribute_lookups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_attribute_lookups (
    id bigint NOT NULL,
    attribute_id bigint NOT NULL,
    lookup_id bigint NOT NULL,
    type_of_assessment character varying NOT NULL,
    schema_version character varying
);


--
-- Name: assessment_attribute_lookups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_attribute_lookups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_attribute_lookups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_attribute_lookups_id_seq OWNED BY public.assessment_attribute_lookups.id;


--
-- Name: assessment_attribute_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_attribute_values (
    attribute_id bigint NOT NULL,
    assessment_id character varying NOT NULL,
    attribute_value character varying,
    attribute_value_int integer,
    attribute_value_float double precision,
    "json" jsonb
);


--
-- Name: assessment_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_attributes (
    attribute_id bigint NOT NULL,
    attribute_name character varying NOT NULL,
    parent_name character varying
);


--
-- Name: assessment_attributes_attribute_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_attributes_attribute_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_attributes_attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_attributes_attribute_id_seq OWNED BY public.assessment_attributes.attribute_id;


--
-- Name: assessment_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_documents (
    assessment_id character varying NOT NULL,
    document jsonb NOT NULL,
    warehouse_created_at timestamp(6) without time zone CONSTRAINT assessment_documents_created_at_not_null NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    matched_uprn bigint
);


--
-- Name: assessment_lookups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_lookups (
    id bigint CONSTRAINT assessment_look_ups_id_not_null NOT NULL,
    lookup_key character varying CONSTRAINT assessment_look_ups_look_up_name_not_null NOT NULL,
    lookup_value character varying CONSTRAINT assessment_look_ups_look_up_value_not_null NOT NULL
);


--
-- Name: assessment_lookups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assessment_lookups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_lookups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessment_lookups_id_seq OWNED BY public.assessment_lookups.id;


--
-- Name: assessment_search; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_search (
    assessment_id character varying NOT NULL,
    address_line_1 character varying,
    address_line_2 character varying,
    address_line_3 character varying,
    address_line_4 character varying,
    post_town character varying(100),
    postcode character varying(10),
    current_energy_efficiency_rating integer,
    current_energy_efficiency_band character varying(2),
    council character varying(40),
    constituency character varying(45),
    assessment_address_id character varying(30),
    address character varying(500),
    registration_date timestamp without time zone NOT NULL,
    assessment_type character varying(8),
    created_at timestamp without time zone,
    uprn bigint,
    schema_type character varying(30),
    country_id bigint
);


--
-- Name: assessments_country_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments_country_ids (
    assessment_id character varying NOT NULL,
    country_id integer
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    assessment_id character varying,
    event_type character varying NOT NULL,
    "timestamp" timestamp(6) without time zone NOT NULL,
    id bigint NOT NULL
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: avg_co2_emissions_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.avg_co2_emissions_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commercial_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commercial_reports (
    assessment_id character varying NOT NULL,
    related_rrn character varying NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    country_code character varying,
    country_name character varying,
    address_base_country_code jsonb,
    country_id integer NOT NULL
);


--
-- Name: mvw_avg_co2_emissions; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_avg_co2_emissions AS
 SELECT nextval('public.avg_co2_emissions_seq'::regclass) AS id,
    avg(((ad.document ->> 'co2_emissions_current_per_floor_area'::text))::double precision) AS avg_co2_emission,
    to_char((((ad.document ->> 'registration_date'::text))::date)::timestamp with time zone, 'YYYY-MM'::text) AS year_month,
        CASE
            WHEN ((co.country_code)::text = ANY ((ARRAY['ENG'::character varying, 'WLS'::character varying, 'NIR'::character varying])::text[])) THEN co.country_name
            WHEN ((co.country_code)::text = 'EAW'::text) THEN 'England'::character varying
            ELSE 'Other'::character varying
        END AS country,
    count(ad.assessment_id) AS cnt,
    (ad.document ->> 'assessment_type'::text) AS assessment_type
   FROM ((public.assessment_documents ad
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
  WHERE (((((ad.document ->> 'assessment_type'::text))::character varying)::text = ANY ((ARRAY['SAP'::character varying, 'RdSAP'::character varying])::text[])) AND ((ad.document ->> 'registration_date'::text) >= '2020-10-01'::text))
  GROUP BY (to_char((((ad.document ->> 'registration_date'::text))::date)::timestamp with time zone, 'YYYY-MM'::text)),
        CASE
            WHEN ((co.country_code)::text = ANY ((ARRAY['ENG'::character varying, 'WLS'::character varying, 'NIR'::character varying])::text[])) THEN co.country_name
            WHEN ((co.country_code)::text = 'EAW'::text) THEN 'England'::character varying
            ELSE 'Other'::character varying
        END, (ad.document ->> 'assessment_type'::text)
  WITH NO DATA;


--
-- Name: mvw_commercial_rr_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_commercial_rr_search AS
 WITH cte AS (
         SELECT ad.assessment_id,
            t.pubseq,
            t.payback_type,
            t.rr_json,
            (ad.document ->> 'related_rrn'::text) AS related_certificate_number
           FROM (public.assessment_documents ad
             CROSS JOIN LATERAL ( VALUES (1,'SHORT'::text,(ad.document -> 'short_payback'::text)), (2,'MEDIUM'::text,(ad.document -> 'medium_payback'::text)), (3,'LONG'::text,(ad.document -> 'long_payback'::text)), (4,'OTHER'::text,(ad.document -> 'other_payback'::text))) t(pubseq, payback_type, rr_json))
          WHERE (EXISTS ( SELECT s.assessment_id,
                    s.address_line_1,
                    s.address_line_2,
                    s.address_line_3,
                    s.address_line_4,
                    s.post_town,
                    s.postcode,
                    s.current_energy_efficiency_rating,
                    s.current_energy_efficiency_band,
                    s.council,
                    s.constituency,
                    s.assessment_address_id,
                    s.address,
                    s.registration_date,
                    s.assessment_type,
                    s.created_at,
                    s.uprn,
                    s.schema_type,
                    s.country_id,
                    co.country_code,
                    co.country_name,
                    co.address_base_country_code,
                    co.country_id
                   FROM (public.assessment_search s
                     JOIN public.countries co ON ((s.country_id = co.country_id)))
                  WHERE (((s.assessment_id)::text = (ad.assessment_id)::text) AND ((s.assessment_type)::text = 'CEPC-RR'::text) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])))))
        )
 SELECT cte.assessment_id AS certificate_number,
    cte.payback_type,
    row_number() OVER (PARTITION BY cte.assessment_id ORDER BY cte.pubseq) AS recommendation_item,
    items.recommendation_code,
    items.recommendation,
    cte.related_certificate_number
   FROM (cte
     CROSS JOIN LATERAL jsonb_to_recordset(cte.rr_json) items(co2_impact character varying, recommendation_code character varying, recommendation character varying))
  WITH NO DATA;


--
-- Name: ons_postcode_directory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ons_postcode_directory (
    postcode character varying(8) NOT NULL,
    country_code character varying(9) NOT NULL,
    region_code character varying(9) NOT NULL,
    local_authority_code character varying(9) NOT NULL,
    westminster_parliamentary_constituency_code character varying(9) CONSTRAINT ons_postcode_directory_westminster_parliamentary_const_not_null NOT NULL,
    other_areas jsonb NOT NULL
);


--
-- Name: ons_postcode_directory_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ons_postcode_directory_names (
    id bigint NOT NULL,
    area_code character varying NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    type_code character varying NOT NULL
);


--
-- Name: mvw_commercial_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_commercial_search AS
 SELECT ad.assessment_id AS certificate_number,
    public.get_attribute_value('address_line_1'::character varying, ad.assessment_id) AS address1,
    public.get_attribute_value('address_line_2'::character varying, ad.assessment_id) AS address2,
    public.get_attribute_value('address_line_3'::character varying, ad.assessment_id) AS address3,
    public.get_attribute_value('postcode'::character varying, ad.assessment_id) AS postcode,
    s.uprn,
    public.get_attribute_value('asset_rating'::character varying, ad.assessment_id) AS asset_rating,
    public.energy_band_calculator((public.get_attribute_value('asset_rating'::character varying, ad.assessment_id))::integer, 'cepc'::character varying) AS asset_rating_band,
    public.get_attribute_value('property_type'::character varying, ad.assessment_id) AS property_type,
    public.get_attribute_value('inspection_date'::character varying, ad.assessment_id) AS inspection_date,
    ons.local_authority_code AS local_authority,
    os_la.area_code AS constituency,
    public.get_lookup_value('transaction_type'::character varying, public.get_attribute_value('transaction_type'::character varying, ad.assessment_id), (t.assessment_type)::character varying, public.get_attribute_value('schema_type'::character varying, ad.assessment_id)) AS transaction_type,
    public.get_attribute_value('registration_date'::character varying, ad.assessment_id) AS lodgement_date,
    public.get_attribute_value('new_build_benchmark'::character varying, ad.assessment_id) AS new_build_benchmark,
    public.get_attribute_value('existing_stock_benchmark'::character varying, ad.assessment_id) AS existing_stock_benchmark,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_level'::text) AS building_level,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'main_heating_fuel'::text) AS main_heating_fuel,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'other_fuel_description'::text) AS other_fuel_desc,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'special_energy_uses'::text) AS special_energy_uses,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'renewable_sources'::text) AS renewable_sources,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'floor_area'::text) AS floor_area,
    public.get_attribute_value('ser'::character varying, ad.assessment_id) AS standard_emissions,
    public.get_attribute_value('ter'::character varying, ad.assessment_id) AS target_emissions,
    public.get_attribute_value('tyr'::character varying, ad.assessment_id) AS typical_emissions,
    public.get_attribute_value('ber'::character varying, ad.assessment_id) AS building_emissions,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_present'::text) AS aircon_present,
        CASE
            WHEN ((((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_rating_unknown_flag'::text))::integer = 1) THEN ''::text
            ELSE ((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_kw_rating'::text)
        END AS aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_estimated_output'::text) AS estimated_aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_inspection_commissioned'::text) AS ac_inspection_commissioned,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_environment'::text) AS building_environment,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.council AS local_authority_label,
    s.constituency AS constituency_label,
    public.get_attribute_value('post_town'::character varying, ad.assessment_id) AS posttown,
    to_char(((ad.document ->> 'created_at'::text))::timestamp with time zone, 'YYYY-MM-DD HH24:MI:SS'::text) AS lodgement_datetime,
    (public.get_attribute_json('energy_use'::character varying, ad.assessment_id) ->> 'energy_consumption_current'::text) AS primary_energy_value,
    public.get_attribute_value('report_type'::character varying, ad.assessment_id) AS report_type,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM (((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('CEPC'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN ( SELECT ad2.assessment_id,
            (ad2.document ->> 'assessment_type'::text) AS assessment_type
           FROM public.assessment_documents ad2) t ON (((t.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_la ON (((ons.westminster_parliamentary_constituency_code)::text = (os_la.area_code)::text)))
  WHERE ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[]))
  WITH NO DATA;


--
-- Name: mvw_dec_rr_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_dec_rr_search AS
 WITH cte AS (
         SELECT ad.assessment_id,
            t.pubseq,
            t.payback_type,
            t.rr_json,
            (ad.document ->> 'related_rrn'::text) AS related_certificate_number
           FROM (public.assessment_documents ad
             CROSS JOIN LATERAL ( VALUES (1,'SHORT'::text,(ad.document -> 'short_payback'::text)), (2,'MEDIUM'::text,(ad.document -> 'medium_payback'::text)), (3,'LONG'::text,(ad.document -> 'long_payback'::text)), (4,'OTHER'::text,(ad.document -> 'other_payback'::text))) t(pubseq, payback_type, rr_json))
          WHERE (EXISTS ( SELECT s.assessment_id,
                    s.address_line_1,
                    s.address_line_2,
                    s.address_line_3,
                    s.address_line_4,
                    s.post_town,
                    s.postcode,
                    s.current_energy_efficiency_rating,
                    s.current_energy_efficiency_band,
                    s.council,
                    s.constituency,
                    s.assessment_address_id,
                    s.address,
                    s.registration_date,
                    s.assessment_type,
                    s.created_at,
                    s.uprn,
                    s.schema_type,
                    s.country_id,
                    co.country_code,
                    co.country_name,
                    co.address_base_country_code,
                    co.country_id
                   FROM (public.assessment_search s
                     JOIN public.countries co ON ((s.country_id = co.country_id)))
                  WHERE (((s.assessment_id)::text = (ad.assessment_id)::text) AND ((s.assessment_type)::text = 'DEC-RR'::text) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])))))
        )
 SELECT cte.assessment_id AS certificate_number,
    cte.payback_type,
    row_number() OVER (PARTITION BY cte.assessment_id ORDER BY cte.pubseq) AS recommendation_item,
    items.recommendation_code,
    items.recommendation,
    cte.related_certificate_number
   FROM (cte
     CROSS JOIN LATERAL jsonb_to_recordset(cte.rr_json) items(co2_impact character varying, recommendation_code character varying, recommendation character varying))
  WITH NO DATA;


--
-- Name: mvw_dec_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_dec_search AS
 SELECT ad.assessment_id AS certificate_number,
    s.address_line_1 AS address1,
    s.address_line_2 AS address2,
    s.address_line_3 AS address3,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.post_town AS posttown,
    s.postcode,
    s.uprn,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS current_operational_rating,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS yr1_operational_rating,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS yr2_operational_rating,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS electric_co2,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS heating_co2,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS renewables_co2,
    public.get_attribute_value('property_type'::character varying, ad.assessment_id) AS property_type,
    public.get_attribute_value('inspection_date'::character varying, ad.assessment_id) AS inspection_date,
    public.get_attribute_value('registration_date'::character varying, ad.assessment_id) AS lodgement_date,
    (public.get_attribute_value('created_at'::character varying, ad.assessment_id))::timestamp without time zone AS lodgement_datetime,
    (public.get_attribute_json('or_benchmark_data'::character varying, ad.assessment_id) ->> 'main_benchmark'::text) AS main_benchmark,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'main_heating_fuel'::text) AS main_heating_fuel,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'special_energy_uses'::text) AS special_energy_uses,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'renewable_sources'::text) AS renewable_sources,
    (round(((public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'floor_area'::text))::numeric))::integer AS total_floor_area,
    (((public.get_attribute_json('or_benchmark_data'::character varying, ad.assessment_id) -> 'benchmarks'::text) -> 0) ->> 'occupancy_level'::text) AS occupancy_level,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'annual_energy_use_fuel_thermal'::text))::numeric))::integer AS annual_thermal_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_thermal_use'::text))::numeric))::integer AS typical_thermal_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'annual_energy_use_electrical'::text))::numeric))::integer AS annual_electrical_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_thermal_use'::text))::numeric))::integer AS typical_thermal_use,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_electrical_use'::text) AS typical_electrical_fuel_usage,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'renewables_fuel_thermal'::text) AS renewables_fuel_thermal,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'renewables_electrical'::text) AS renewables_electrical,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS yr1_electricity_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS yr2_electricity_co2,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS yr1_heating_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS yr2_heating_co2,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS yr1_renewables_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS yr2_renewables_co2,
        CASE (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_present'::text)
            WHEN 'Yes'::text THEN 'Y'::text
            WHEN 'No'::text THEN 'N'::text
            ELSE NULL::text
        END AS aircon_present,
        CASE
            WHEN (((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_rating_unknown_flag'::text) = ANY (ARRAY['1'::text, 'true'::text])) THEN ''::text
            ELSE ((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_kw_rating'::text)
        END AS aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_estimated_output'::text) AS estimated_aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_inspection_commissioned'::text) AS ac_inspection_commissioned,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_environment'::text) AS building_environment,
    public.get_attribute_value('building_category'::character varying, ad.assessment_id) AS building_category,
    public.energy_band_calculator(((public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) -> 'energy_rating'::text))::integer, ((ad.document ->> 'assessment_type'::text))::character varying) AS operational_rating_band,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'nominated_date'::text) AS nominated_date,
    public.get_attribute_value('or_assessment_end_date'::character varying, ad.assessment_id) AS or_assessment_end_date,
    public.get_attribute_value('report_type'::character varying, ad.assessment_id) AS report_type,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'other_fuel_description'::text) AS other_fuel,
    co.country_name AS country,
    ons.local_authority_code AS local_authority,
    s.council AS local_authority_label,
    os_la.area_code AS constituency,
    s.constituency AS constituency_label,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM (((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('DEC'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN ( SELECT ad2.assessment_id,
            (ad2.document ->> 'assessment_type'::text) AS assessment_type
           FROM public.assessment_documents ad2) t ON (((t.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_la ON (((ons.westminster_parliamentary_constituency_code)::text = (os_la.area_code)::text)))
  WHERE ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[]))
  WITH NO DATA;


--
-- Name: mvw_domestic_rr_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_domestic_rr_search AS
 SELECT aav.assessment_id AS certificate_number,
    items.sequence AS improvement_item,
    (items.improvement_details ->> 'improvement_number'::text) AS improvement_id,
    items.indicative_cost,
        CASE
            WHEN ((items.improvement_details -> 'improvement_texts'::text) IS NULL) THEN public.get_lookup_value('improvement_summary'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
            ELSE (((items.improvement_details -> 'improvement_texts'::text) ->> 'improvement_summary'::text))::character varying
        END AS improvement_summary_text,
        CASE
            WHEN ((items.improvement_details -> 'improvement_texts'::text) IS NULL) THEN public.get_lookup_value('improvement_description'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
            ELSE (((items.improvement_details -> 'improvement_texts'::text) ->> 'improvement_description'::text))::character varying
        END AS improvement_descr_text
   FROM ((((((public.assessment_attribute_values aav
     CROSS JOIN LATERAL json_to_recordset(
        CASE
            WHEN (jsonb_typeof(aav."json") = 'array'::text) THEN (aav."json")::json
            ELSE json_build_array((aav."json" -> 'improvement'::text))
        END) items(sequence integer, indicative_cost character varying, improvement_type character varying, improvement_category character varying, improvement_details json))
     JOIN public.assessment_documents ad ON (((ad.assessment_id)::text = (aav.assessment_id)::text)))
     JOIN public.assessment_attributes aa ON ((aa.attribute_id = aav.attribute_id)))
     JOIN ( SELECT aav1.assessment_id,
            aav1.attribute_value AS schema_type
           FROM (public.assessment_attribute_values aav1
             JOIN public.assessment_attributes a1 ON ((aav1.attribute_id = a1.attribute_id)))
          WHERE ((a1.attribute_name)::text = 'schema_type'::text)) s ON (((s.assessment_id)::text = (aav.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((aav.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
  WHERE (((aa.attribute_name)::text = 'suggested_improvements'::text) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((ad.document ->> 'assessment_type'::text) = ANY (ARRAY['SAP'::text, 'RdSAP'::text])))
  WITH NO DATA;


--
-- Name: mvw_domestic_rr_search_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mvw_domestic_rr_search_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mvw_domestic_search; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mvw_domestic_search AS
 SELECT ad.assessment_id AS certificate_number,
    s.address_line_1 AS address1,
    s.address_line_2 AS address2,
    s.address_line_3 AS address3,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.postcode,
    (ad.document ->> 'inspection_date'::text) AS inspection_date,
    s.uprn,
    (ad.document ->> 'environmental_impact_potential'::text) AS environment_impact_potential,
    (ad.document ->> 'energy_consumption_current'::text) AS energy_consumption_current,
    (ad.document ->> 'energy_consumption_potential'::text) AS energy_consumption_potential,
    (ad.document ->> 'environmental_impact_current'::text) AS environment_impact_current,
    (ad.document ->> 'co2_emissions_current'::text) AS co2_emissions_current,
    (ad.document ->> 'co2_emissions_current_per_floor_area'::text) AS co2_emiss_curr_per_floor_area,
    (ad.document ->> 'co2_emissions_potential'::text) AS co2_emissions_potential,
    (ad.document ->> 'total_floor_area'::text) AS total_floor_area,
    to_char(s.registration_date, 'yyyy-mm-dd'::text) AS lodgement_date,
    (ad.document ->> 'report_type'::text) AS report_type,
    s.post_town AS posttown,
    to_char(((ad.document ->> 'created_at'::text))::timestamp with time zone, 'YYYY-MM-DD HH24:MI:SS'::text) AS lodgement_datetime,
    (s.current_energy_efficiency_rating)::character varying AS current_energy_efficiency,
    s.current_energy_efficiency_band AS current_energy_rating,
    (ad.document ->> 'energy_rating_potential'::text) AS potential_energy_efficiency,
    public.energy_band_calculator(((ad.document ->> 'energy_rating_potential'::text))::integer, s.assessment_type) AS potential_energy_rating,
    (ad.document ->> 'extensions_count'::text) AS extension_count,
    COALESCE((ad.document ->> 'open_fireplaces_count'::text), (ad.document ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_fireplaces_count'::text)) AS number_open_fireplaces,
    (ad.document ->> 'heated_room_count'::text) AS number_heated_rooms,
    (ad.document ->> 'habitable_room_count'::text) AS number_habitable_rooms,
    COALESCE((ad.document ->> 'low_energy_lighting'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_percentage'::text), (round(((public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id) / NULLIF(public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id), (0)::numeric)) * (100)::numeric)))::text, ( SELECT (round(((((sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::numeric)::double precision / NULLIF(sum(((sl.value ->> 'lighting_outlets'::text))::double precision), (0)::double precision)) * (100)::double precision)))::text AS round
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_lighting,
    COALESCE((ad.document ->> 'low_energy_fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT (sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_fixed_lighting_outlets_count,
    (ad.document ->> 'solar_water_heating'::text) AS solar_water_heating_flag,
    public.get_lookup_value('mechanical_ventilation'::character varying, ((ad.document ->> 'mechanical_ventilation'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mechanical_ventilation,
    public.get_lookup_value('tenure'::character varying, ((ad.document ->> 'tenure'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS tenure,
    public.get_lookup_value('property_type'::character varying, ((ad.document ->> 'property_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS property_type,
    public.get_lookup_value('transaction_type'::character varying, ((ad.document ->> 'transaction_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS transaction_type,
    public.fn_construction_age_band(ad.document, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS construction_age_band,
    public.get_lookup_value('built_form'::character varying, ((ad.document ->> 'built_form'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS built_form,
        CASE
            WHEN ((s.assessment_type)::text = 'RdSAP'::text) THEN public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'meter_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
            ELSE public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'electricity_tariff'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
        END AS energy_tariff,
    public.get_lookup_value('glazed_type'::character varying, ((ad.document ->> 'multiple_glazing_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_type,
    public.get_lookup_value('glazed_area'::character varying, ((ad.document ->> 'glazed_area'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_area,
    public.get_lookup_value('heat_loss_corridor'::character varying, (((ad.document -> 'sap_flat_details'::text) ->> 'heat_loss_corridor'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS heat_loss_corridor,
    public.get_lookup_value('main_fuel'::character varying, (COALESCE(((ad.document -> 'sap_heating'::text) ->> 'main_fuel_type'::text), ((((ad.document -> 'sap_heating'::text) -> 'main_heating_details'::text) -> 0) ->> 'main_fuel_type'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS main_fuel,
    COALESCE((((ad.document -> 'sap_flat_details'::text) -> 'unheated_corridor_length'::text) ->> 'value'::text), ((ad.document -> 'sap_flat_details'::text) ->> 'unheated_corridor_length'::text)) AS unheated_corridor_length,
    ((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) AS floor_level,
    COALESCE(((ad.document -> 'sap_flat_details'::text) ->> 'top_storey'::text),
        CASE
            WHEN (((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) = '3'::text) THEN 'Y'::text
            ELSE 'N'::text
        END) AS flat_top_storey,
    jsonb_array_length((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text)) AS flat_storey_count,
    COALESCE(((ad.document -> 'sap_energy_source'::text) ->> 'mains_gas'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'main_gas'::text)) AS mains_gas_flag,
    COALESCE(((((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) -> 'none_or_no_details'::text) ->> 'percent_roof_area'::text), (((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) ->> 'percent_roof_area'::text), (ad.document ->> 'photovoltaic_supply'::text)) AS photo_supply,
    COALESCE((((ad.document -> 'sap_energy_source'::text) ->> 'wind_turbines_count'::text))::integer, jsonb_array_length(((ad.document -> 'sap_energy_source'::text) -> 'wind_turbines'::text))) AS wind_turbine_count,
    COALESCE(((ad.document -> 'lighting_cost_current'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_current'::text)) AS lighting_cost_current,
    COALESCE(((ad.document -> 'lighting_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_potential'::text)) AS lighting_cost_potential,
    COALESCE(((ad.document -> 'heating_cost_current'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_current'::text)) AS heating_cost_current,
    COALESCE(((ad.document -> 'heating_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_potential'::text)) AS heating_cost_potential,
    COALESCE(((ad.document -> 'hot_water_cost_current'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_current'::text)) AS hot_water_cost_current,
    COALESCE(((ad.document -> 'hot_water_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_potential'::text)) AS hot_water_cost_potential,
    COALESCE((ad.document ->> 'multiple_glazed_percentage'::text), (ad.document ->> 'multiple_glazed_proportion'::text)) AS multi_glaze_proportion,
    public.fn_clean_description((COALESCE((((ad.document -> 'hot_water'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'hot_water'::text) ->> 'description'::text)))::character varying) AS hotwater_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'floors'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'floors'::text) -> 0) ->> 'description'::text)))::character varying) AS floor_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'roofs'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'roofs'::text) -> 0) ->> 'description'::text)))::character varying) AS roof_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'walls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'walls'::text) -> 0) ->> 'description'::text)))::character varying) AS walls_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_env_eff,
    public.fn_clean_description((COALESCE(((ad.document -> 'window'::text) ->> 'description'::text), (((ad.document -> 'window'::text) -> 0) ->> 'description'::text), ((ad.document -> 'windows'::text) ->> 'description'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'description'::text)))::character varying) AS windows_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'energy_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'energy_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'environmental_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'environmental_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_env_eff,
    COALESCE((((ad.document -> 'secondary_heating'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'secondary_heating'::text) ->> 'description'::text)) AS secondheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_env_eff,
    ( SELECT public.fn_clean_description((COALESCE(string_agg(((mh.value -> 'description'::text) ->> 'value'::text), ', '::text), string_agg((mh.value ->> 'description'::text), ', '::text)))::character varying) AS mainheat_description
           FROM jsonb_array_elements((ad.document -> 'main_heating'::text)) mh(value)) AS mainheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS mainheatcont_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_env_eff,
    public.fn_clean_description((COALESCE((((ad.document -> 'lighting'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'lighting'::text) ->> 'description'::text)))::character varying) AS lighting_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_env_eff,
    COALESCE((ad.document ->> 'fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT ((sum(COALESCE(((sl.value ->> 'lighting_outlets'::text))::integer, 0)))::integer)::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS fixed_lighting_outlets_count,
    COALESCE(((((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) -> 'room_height'::text) ->> 'value'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'storey_height'::text), (((ad.document -> 'sap_building_parts'::text) -> 0) ->> 'room_height'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'room_height'::text)) AS floor_height,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS main_heating_controls,
    ons.local_authority_code AS local_authority,
    s.council AS local_authority_label,
    s.constituency AS constituency_label,
    os_p.area_code AS constituency,
    co.country_name AS country,
    ons.region_code AS region,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM ((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('SAP'::text), ('RdSAP'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_p ON (((ons.westminster_parliamentary_constituency_code)::text = (os_p.area_code)::text)))
  WHERE ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[]))
  WITH NO DATA;


--
-- Name: ons_postcode_directory_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ons_postcode_directory_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ons_postcode_directory_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ons_postcode_directory_names_id_seq OWNED BY public.ons_postcode_directory_names.id;


--
-- Name: ons_postcode_directory_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ons_postcode_directory_versions (
    id integer NOT NULL,
    version_month character varying(7) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ons_postcode_directory_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ons_postcode_directory_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ons_postcode_directory_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ons_postcode_directory_versions_id_seq OWNED BY public.ons_postcode_directory_versions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: vw_commercial_rr_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_commercial_rr_yesterday AS
 WITH cte AS (
         SELECT ad.assessment_id,
            t.pubseq,
            t.payback_type,
            t.rr_json,
            (ad.document ->> 'related_rrn'::text) AS related_certificate_number
           FROM (public.assessment_documents ad
             CROSS JOIN LATERAL ( VALUES (1,'SHORT'::text,(ad.document -> 'short_payback'::text)), (2,'MEDIUM'::text,(ad.document -> 'medium_payback'::text)), (3,'LONG'::text,(ad.document -> 'long_payback'::text)), (4,'OTHER'::text,(ad.document -> 'other_payback'::text))) t(pubseq, payback_type, rr_json))
          WHERE (EXISTS ( SELECT s.assessment_id,
                    s.address_line_1,
                    s.address_line_2,
                    s.address_line_3,
                    s.address_line_4,
                    s.post_town,
                    s.postcode,
                    s.current_energy_efficiency_rating,
                    s.current_energy_efficiency_band,
                    s.council,
                    s.constituency,
                    s.assessment_address_id,
                    s.address,
                    s.registration_date,
                    s.assessment_type,
                    s.created_at,
                    s.uprn,
                    s.schema_type,
                    s.country_id,
                    co.country_code,
                    co.country_name,
                    co.address_base_country_code,
                    co.country_id
                   FROM (public.assessment_search s
                     JOIN public.countries co ON ((s.country_id = co.country_id)))
                  WHERE (((s.assessment_id)::text = (ad.assessment_id)::text) AND ((s.assessment_type)::text = 'CEPC-RR'::text) AND ((s.created_at)::date = (CURRENT_DATE - 1)) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])))))
        )
 SELECT cte.assessment_id AS certificate_number,
    cte.payback_type,
    row_number() OVER (PARTITION BY cte.assessment_id ORDER BY cte.pubseq) AS recommendation_item,
    items.recommendation_code,
    items.recommendation,
    cte.related_certificate_number
   FROM (cte
     CROSS JOIN LATERAL jsonb_to_recordset(cte.rr_json) items(co2_impact character varying, recommendation_code character varying, recommendation character varying));


--
-- Name: vw_commercial_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_commercial_yesterday AS
 SELECT ad.assessment_id AS certificate_number,
    public.get_attribute_value('address_line_1'::character varying, ad.assessment_id) AS address1,
    public.get_attribute_value('address_line_2'::character varying, ad.assessment_id) AS address2,
    public.get_attribute_value('address_line_3'::character varying, ad.assessment_id) AS address3,
    public.get_attribute_value('postcode'::character varying, ad.assessment_id) AS postcode,
    s.uprn,
    public.get_attribute_value('asset_rating'::character varying, ad.assessment_id) AS asset_rating,
    public.energy_band_calculator((public.get_attribute_value('asset_rating'::character varying, ad.assessment_id))::integer, 'cepc'::character varying) AS asset_rating_band,
    public.get_attribute_value('property_type'::character varying, ad.assessment_id) AS property_type,
    public.get_attribute_value('inspection_date'::character varying, ad.assessment_id) AS inspection_date,
    ons.local_authority_code AS local_authority,
    os_la.area_code AS constituency,
    public.get_lookup_value('transaction_type'::character varying, public.get_attribute_value('transaction_type'::character varying, ad.assessment_id), (t.assessment_type)::character varying, public.get_attribute_value('schema_type'::character varying, ad.assessment_id)) AS transaction_type,
    public.get_attribute_value('registration_date'::character varying, ad.assessment_id) AS lodgement_date,
    public.get_attribute_value('new_build_benchmark'::character varying, ad.assessment_id) AS new_build_benchmark,
    public.get_attribute_value('existing_stock_benchmark'::character varying, ad.assessment_id) AS existing_stock_benchmark,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_level'::text) AS building_level,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'main_heating_fuel'::text) AS main_heating_fuel,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'other_fuel_description'::text) AS other_fuel_desc,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'special_energy_uses'::text) AS special_energy_uses,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'renewable_sources'::text) AS renewable_sources,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'floor_area'::text) AS floor_area,
    public.get_attribute_value('ser'::character varying, ad.assessment_id) AS standard_emissions,
    public.get_attribute_value('ter'::character varying, ad.assessment_id) AS target_emissions,
    public.get_attribute_value('tyr'::character varying, ad.assessment_id) AS typical_emissions,
    public.get_attribute_value('ber'::character varying, ad.assessment_id) AS building_emissions,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_present'::text) AS aircon_present,
        CASE
            WHEN ((((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_rating_unknown_flag'::text))::integer = 1) THEN ''::text
            ELSE ((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_kw_rating'::text)
        END AS aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_estimated_output'::text) AS estimated_aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_inspection_commissioned'::text) AS ac_inspection_commissioned,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_environment'::text) AS building_environment,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.council AS local_authority_label,
    s.constituency AS constituency_label,
    public.get_attribute_value('post_town'::character varying, ad.assessment_id) AS posttown,
    to_char(((ad.document ->> 'created_at'::text))::timestamp with time zone, 'YYYY-MM-DD HH24:MI:SS'::text) AS lodgement_datetime,
    (public.get_attribute_json('energy_use'::character varying, ad.assessment_id) ->> 'energy_consumption_current'::text) AS primary_energy_value,
    public.get_attribute_value('report_type'::character varying, ad.assessment_id) AS report_type,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM (((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('CEPC'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN ( SELECT ad2.assessment_id,
            (ad2.document ->> 'assessment_type'::text) AS assessment_type
           FROM public.assessment_documents ad2) t ON (((t.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_la ON (((ons.westminster_parliamentary_constituency_code)::text = (os_la.area_code)::text)))
  WHERE ((((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((s.created_at)::date = (CURRENT_DATE - 1))) OR (EXISTS ( SELECT l.assessment_id,
            l.event_type,
            l."timestamp",
            l.id
           FROM public.audit_logs l
          WHERE (((s.assessment_id)::text = (l.assessment_id)::text) AND ((l.event_type)::text = 'address_id_updated'::text) AND ((l."timestamp")::date = (CURRENT_DATE - 1))))));


--
-- Name: vw_dec_rr_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_dec_rr_yesterday AS
 WITH cte AS (
         SELECT ad.assessment_id,
            t.pubseq,
            t.payback_type,
            t.rr_json,
            (ad.document ->> 'related_rrn'::text) AS related_certificate_number
           FROM (public.assessment_documents ad
             CROSS JOIN LATERAL ( VALUES (1,'SHORT'::text,(ad.document -> 'short_payback'::text)), (2,'MEDIUM'::text,(ad.document -> 'medium_payback'::text)), (3,'LONG'::text,(ad.document -> 'long_payback'::text)), (4,'OTHER'::text,(ad.document -> 'other_payback'::text))) t(pubseq, payback_type, rr_json))
          WHERE (EXISTS ( SELECT s.assessment_id,
                    s.address_line_1,
                    s.address_line_2,
                    s.address_line_3,
                    s.address_line_4,
                    s.post_town,
                    s.postcode,
                    s.current_energy_efficiency_rating,
                    s.current_energy_efficiency_band,
                    s.council,
                    s.constituency,
                    s.assessment_address_id,
                    s.address,
                    s.registration_date,
                    s.assessment_type,
                    s.created_at,
                    s.uprn,
                    s.schema_type,
                    s.country_id,
                    co.country_code,
                    co.country_name,
                    co.address_base_country_code,
                    co.country_id
                   FROM (public.assessment_search s
                     JOIN public.countries co ON ((s.country_id = co.country_id)))
                  WHERE (((s.assessment_id)::text = (ad.assessment_id)::text) AND ((s.assessment_type)::text = 'DEC-RR'::text) AND ((s.created_at)::date = (CURRENT_DATE - 1)) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])))))
        )
 SELECT cte.assessment_id AS certificate_number,
    cte.payback_type,
    row_number() OVER (PARTITION BY cte.assessment_id ORDER BY cte.pubseq) AS recommendation_item,
    items.recommendation_code,
    items.recommendation,
    cte.related_certificate_number
   FROM (cte
     CROSS JOIN LATERAL jsonb_to_recordset(cte.rr_json) items(co2_impact character varying, recommendation_code character varying, recommendation character varying));


--
-- Name: vw_dec_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_dec_yesterday AS
 SELECT ad.assessment_id AS certificate_number,
    s.address_line_1 AS address1,
    s.address_line_2 AS address2,
    s.address_line_3 AS address3,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.post_town AS posttown,
    s.postcode,
    s.uprn,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS current_operational_rating,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS yr1_operational_rating,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'energy_rating'::text) AS yr2_operational_rating,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS electric_co2,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS heating_co2,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS renewables_co2,
    public.get_attribute_value('property_type'::character varying, ad.assessment_id) AS property_type,
    public.get_attribute_value('inspection_date'::character varying, ad.assessment_id) AS inspection_date,
    public.get_attribute_value('registration_date'::character varying, ad.assessment_id) AS lodgement_date,
    (public.get_attribute_value('created_at'::character varying, ad.assessment_id))::timestamp without time zone AS lodgement_datetime,
    (public.get_attribute_json('or_benchmark_data'::character varying, ad.assessment_id) ->> 'main_benchmark'::text) AS main_benchmark,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'main_heating_fuel'::text) AS main_heating_fuel,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'special_energy_uses'::text) AS special_energy_uses,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'renewable_sources'::text) AS renewable_sources,
    (round(((public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'floor_area'::text))::numeric))::integer AS total_floor_area,
    (((public.get_attribute_json('or_benchmark_data'::character varying, ad.assessment_id) -> 'benchmarks'::text) -> 0) ->> 'occupancy_level'::text) AS occupancy_level,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'annual_energy_use_fuel_thermal'::text))::numeric))::integer AS annual_thermal_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_thermal_use'::text))::numeric))::integer AS typical_thermal_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'annual_energy_use_electrical'::text))::numeric))::integer AS annual_electrical_fuel_usage,
    (round(((public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_thermal_use'::text))::numeric))::integer AS typical_thermal_use,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'typical_electrical_use'::text) AS typical_electrical_fuel_usage,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'renewables_fuel_thermal'::text) AS renewables_fuel_thermal,
    (public.get_attribute_json('dec_annual_energy_summary'::character varying, ad.assessment_id) ->> 'renewables_electrical'::text) AS renewables_electrical,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS yr1_electricity_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'electricity_co2'::text) AS yr2_electricity_co2,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS yr1_heating_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'heating_co2'::text) AS yr2_heating_co2,
    (public.get_attribute_json('year1_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS yr1_renewables_co2,
    (public.get_attribute_json('year2_assessment'::character varying, ad.assessment_id) ->> 'renewables_co2'::text) AS yr2_renewables_co2,
        CASE (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_present'::text)
            WHEN 'Yes'::text THEN 'Y'::text
            WHEN 'No'::text THEN 'N'::text
            ELSE NULL::text
        END AS aircon_present,
        CASE
            WHEN (((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_rating_unknown_flag'::text) = ANY (ARRAY['1'::text, 'true'::text])) THEN ''::text
            ELSE ((public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) -> 'ac_rated_output'::text) ->> 'ac_kw_rating'::text)
        END AS aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_estimated_output'::text) AS estimated_aircon_kw_rating,
    (public.get_attribute_json('ac_questionnaire'::character varying, ad.assessment_id) ->> 'ac_inspection_commissioned'::text) AS ac_inspection_commissioned,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'building_environment'::text) AS building_environment,
    public.get_attribute_value('building_category'::character varying, ad.assessment_id) AS building_category,
    public.energy_band_calculator(((public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) -> 'energy_rating'::text))::integer, ((ad.document ->> 'assessment_type'::text))::character varying) AS operational_rating_band,
    (public.get_attribute_json('this_assessment'::character varying, ad.assessment_id) ->> 'nominated_date'::text) AS nominated_date,
    public.get_attribute_value('or_assessment_end_date'::character varying, ad.assessment_id) AS or_assessment_end_date,
    public.get_attribute_value('report_type'::character varying, ad.assessment_id) AS report_type,
    (public.get_attribute_json('technical_information'::character varying, ad.assessment_id) ->> 'other_fuel_description'::text) AS other_fuel,
    co.country_name AS country,
    ons.local_authority_code AS local_authority,
    s.council AS local_authority_label,
    os_la.area_code AS constituency,
    s.constituency AS constituency_label,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM (((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('DEC'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN ( SELECT ad2.assessment_id,
            (ad2.document ->> 'assessment_type'::text) AS assessment_type
           FROM public.assessment_documents ad2) t ON (((t.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_la ON (((ons.westminster_parliamentary_constituency_code)::text = (os_la.area_code)::text)))
  WHERE ((((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((s.created_at)::date = (CURRENT_DATE - 1))) OR (EXISTS ( SELECT l.assessment_id,
            l.event_type,
            l."timestamp",
            l.id
           FROM public.audit_logs l
          WHERE (((s.assessment_id)::text = (l.assessment_id)::text) AND ((l.event_type)::text = 'address_id_updated'::text) AND ((l."timestamp")::date = (CURRENT_DATE - 1))))));


--
-- Name: vw_domestic_base; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_domestic_base AS
 SELECT ad.assessment_id AS certificate_number,
    s.address_line_1 AS address1,
    s.address_line_2 AS address2,
    s.address_line_3 AS address3,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.postcode,
    (ad.document ->> 'inspection_date'::text) AS inspection_date,
    s.uprn,
    (ad.document ->> 'environmental_impact_potential'::text) AS environment_impact_potential,
    (ad.document ->> 'energy_consumption_current'::text) AS energy_consumption_current,
    (ad.document ->> 'energy_consumption_potential'::text) AS energy_consumption_potential,
    (ad.document ->> 'environmental_impact_current'::text) AS environment_impact_current,
    (ad.document ->> 'co2_emissions_current'::text) AS co2_emissions_current,
    (ad.document ->> 'co2_emissions_current_per_floor_area'::text) AS co2_emiss_curr_per_floor_area,
    (ad.document ->> 'co2_emissions_potential'::text) AS co2_emissions_potential,
    (ad.document ->> 'total_floor_area'::text) AS total_floor_area,
    to_char(s.registration_date, 'yyyy-mm-dd'::text) AS lodgement_date,
    (ad.document ->> 'report_type'::text) AS report_type,
    s.post_town AS posttown,
    to_char(((ad.document ->> 'created_at'::text))::timestamp with time zone, 'YYYY-MM-DD HH24:MI:SS'::text) AS lodgement_datetime,
    (s.current_energy_efficiency_rating)::character varying AS current_energy_efficiency,
    s.current_energy_efficiency_band AS current_energy_rating,
    (ad.document ->> 'energy_rating_potential'::text) AS potential_energy_efficiency,
    public.energy_band_calculator(((ad.document ->> 'energy_rating_potential'::text))::integer, s.assessment_type) AS potential_energy_rating,
    (ad.document ->> 'extensions_count'::text) AS extension_count,
    COALESCE((ad.document ->> 'open_fireplaces_count'::text), (ad.document ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_fireplaces_count'::text)) AS number_open_fireplaces,
    (ad.document ->> 'heated_room_count'::text) AS number_heated_rooms,
    (ad.document ->> 'habitable_room_count'::text) AS number_habitable_rooms,
    COALESCE((ad.document ->> 'low_energy_lighting'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_percentage'::text), (round(((public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id) / NULLIF(public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id), (0)::numeric)) * (100)::numeric)))::text, ( SELECT (round(((((sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::numeric)::double precision / NULLIF(sum(((sl.value ->> 'lighting_outlets'::text))::double precision), (0)::double precision)) * (100)::double precision)))::text AS round
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_lighting,
    COALESCE((ad.document ->> 'low_energy_fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT (sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_fixed_lighting_outlets_count,
    (ad.document ->> 'solar_water_heating'::text) AS solar_water_heating_flag,
    public.get_lookup_value('mechanical_ventilation'::character varying, ((ad.document ->> 'mechanical_ventilation'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mechanical_ventilation,
    public.get_lookup_value('tenure'::character varying, ((ad.document ->> 'tenure'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS tenure,
    public.get_lookup_value('property_type'::character varying, ((ad.document ->> 'property_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS property_type,
    public.get_lookup_value('transaction_type'::character varying, ((ad.document ->> 'transaction_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS transaction_type,
    public.fn_construction_age_band(ad.document, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS construction_age_band,
    public.get_lookup_value('built_form'::character varying, ((ad.document ->> 'built_form'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS built_form,
        CASE
            WHEN ((s.assessment_type)::text = 'RdSAP'::text) THEN public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'meter_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
            ELSE public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'electricity_tariff'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
        END AS energy_tariff,
    public.get_lookup_value('glazed_type'::character varying, ((ad.document ->> 'multiple_glazing_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_type,
    public.get_lookup_value('glazed_area'::character varying, ((ad.document ->> 'glazed_area'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_area,
    public.get_lookup_value('heat_loss_corridor'::character varying, (((ad.document -> 'sap_flat_details'::text) ->> 'heat_loss_corridor'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS heat_loss_corridor,
    public.get_lookup_value('main_fuel'::character varying, (COALESCE(((ad.document -> 'sap_heating'::text) ->> 'main_fuel_type'::text), ((((ad.document -> 'sap_heating'::text) -> 'main_heating_details'::text) -> 0) ->> 'main_fuel_type'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS main_fuel,
    COALESCE((((ad.document -> 'sap_flat_details'::text) -> 'unheated_corridor_length'::text) ->> 'value'::text), ((ad.document -> 'sap_flat_details'::text) ->> 'unheated_corridor_length'::text)) AS unheated_corridor_length,
    ((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) AS floor_level,
    COALESCE(((ad.document -> 'sap_flat_details'::text) ->> 'top_storey'::text),
        CASE
            WHEN (((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) = '3'::text) THEN 'Y'::text
            ELSE 'N'::text
        END) AS flat_top_storey,
    jsonb_array_length((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text)) AS flat_storey_count,
    COALESCE(((ad.document -> 'sap_energy_source'::text) ->> 'mains_gas'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'main_gas'::text)) AS mains_gas_flag,
    COALESCE(((((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) -> 'none_or_no_details'::text) ->> 'percent_roof_area'::text), (((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) ->> 'percent_roof_area'::text), (ad.document ->> 'photovoltaic_supply'::text)) AS photo_supply,
    COALESCE((((ad.document -> 'sap_energy_source'::text) ->> 'wind_turbines_count'::text))::integer, jsonb_array_length(((ad.document -> 'sap_energy_source'::text) -> 'wind_turbines'::text))) AS wind_turbine_count,
    COALESCE(((ad.document -> 'lighting_cost_current'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_current'::text)) AS lighting_cost_current,
    COALESCE(((ad.document -> 'lighting_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_potential'::text)) AS lighting_cost_potential,
    COALESCE(((ad.document -> 'heating_cost_current'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_current'::text)) AS heating_cost_current,
    COALESCE(((ad.document -> 'heating_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_potential'::text)) AS heating_cost_potential,
    COALESCE(((ad.document -> 'hot_water_cost_current'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_current'::text)) AS hot_water_cost_current,
    COALESCE(((ad.document -> 'hot_water_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_potential'::text)) AS hot_water_cost_potential,
    COALESCE((ad.document ->> 'multiple_glazed_percentage'::text), (ad.document ->> 'multiple_glazed_proportion'::text)) AS multi_glaze_proportion,
    public.fn_clean_description((COALESCE((((ad.document -> 'hot_water'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'hot_water'::text) ->> 'description'::text)))::character varying) AS hotwater_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'floors'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'floors'::text) -> 0) ->> 'description'::text)))::character varying) AS floor_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'roofs'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'roofs'::text) -> 0) ->> 'description'::text)))::character varying) AS roof_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'walls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'walls'::text) -> 0) ->> 'description'::text)))::character varying) AS walls_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_env_eff,
    public.fn_clean_description((COALESCE(((ad.document -> 'window'::text) ->> 'description'::text), (((ad.document -> 'window'::text) -> 0) ->> 'description'::text), ((ad.document -> 'windows'::text) ->> 'description'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'description'::text)))::character varying) AS windows_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'energy_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'energy_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'environmental_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'environmental_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_env_eff,
    COALESCE((((ad.document -> 'secondary_heating'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'secondary_heating'::text) ->> 'description'::text)) AS secondheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_env_eff,
    ( SELECT public.fn_clean_description((COALESCE(string_agg(((mh.value -> 'description'::text) ->> 'value'::text), ', '::text), string_agg((mh.value ->> 'description'::text), ', '::text)))::character varying) AS mainheat_description
           FROM jsonb_array_elements((ad.document -> 'main_heating'::text)) mh(value)) AS mainheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS mainheatcont_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_env_eff,
    public.fn_clean_description((COALESCE((((ad.document -> 'lighting'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'lighting'::text) ->> 'description'::text)))::character varying) AS lighting_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_env_eff,
    COALESCE((ad.document ->> 'fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT ((sum(COALESCE(((sl.value ->> 'lighting_outlets'::text))::integer, 0)))::integer)::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS fixed_lighting_outlets_count,
    COALESCE(((((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) -> 'room_height'::text) ->> 'value'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'storey_height'::text), (((ad.document -> 'sap_building_parts'::text) -> 0) ->> 'room_height'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'room_height'::text)) AS floor_height,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS main_heating_controls,
    ons.local_authority_code AS local_authority,
    s.council AS local_authority_label,
    s.constituency AS constituency_label,
    os_p.area_code AS constituency,
    co.country_name AS country,
    ons.region_code AS region,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM ((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('SAP'::text), ('RdSAP'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_p ON (((ons.westminster_parliamentary_constituency_code)::text = (os_p.area_code)::text)))
  WHERE ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[]));


--
-- Name: vw_domestic_rr_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_domestic_rr_yesterday AS
 SELECT aav.assessment_id AS certificate_number,
    items.sequence AS improvement_item,
    (items.improvement_details ->> 'improvement_number'::text) AS improvement_id,
    items.indicative_cost,
        CASE
            WHEN ((items.improvement_details -> 'improvement_texts'::text) IS NULL) THEN public.get_lookup_value('improvement_summary'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
            ELSE (((items.improvement_details -> 'improvement_texts'::text) ->> 'improvement_summary'::text))::character varying
        END AS improvement_summary_text,
        CASE
            WHEN ((items.improvement_details -> 'improvement_texts'::text) IS NULL) THEN public.get_lookup_value('improvement_description'::character varying, ((items.improvement_details ->> 'improvement_number'::text))::character varying, ((ad.document ->> 'assessment_type'::text))::character varying, s.schema_type)
            ELSE (((items.improvement_details -> 'improvement_texts'::text) ->> 'improvement_description'::text))::character varying
        END AS improvement_descr_text
   FROM ((((((public.assessment_attribute_values aav
     CROSS JOIN LATERAL json_to_recordset(
        CASE
            WHEN (jsonb_typeof(aav."json") = 'array'::text) THEN (aav."json")::json
            ELSE json_build_array((aav."json" -> 'improvement'::text))
        END) items(sequence integer, indicative_cost character varying, improvement_type character varying, improvement_category character varying, improvement_details json))
     JOIN public.assessment_documents ad ON (((ad.assessment_id)::text = (aav.assessment_id)::text)))
     JOIN public.assessment_attributes aa ON ((aa.attribute_id = aav.attribute_id)))
     JOIN ( SELECT aav1.assessment_id,
            aav1.attribute_value AS schema_type
           FROM (public.assessment_attribute_values aav1
             JOIN public.assessment_attributes a1 ON ((aav1.attribute_id = a1.attribute_id)))
          WHERE ((a1.attribute_name)::text = 'schema_type'::text)) s ON (((s.assessment_id)::text = (aav.assessment_id)::text)))
     JOIN public.assessments_country_ids aci ON (((aav.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
  WHERE (((aa.attribute_name)::text = 'suggested_improvements'::text) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((ad.document ->> 'assessment_type'::text) = ANY (ARRAY['SAP'::text, 'RdSAP'::text])) AND ((ad.warehouse_created_at)::date = (CURRENT_DATE - 1)));


--
-- Name: vw_domestic_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_domestic_yesterday AS
 SELECT ad.assessment_id AS certificate_number,
    s.address_line_1 AS address1,
    s.address_line_2 AS address2,
    s.address_line_3 AS address3,
    concat_ws(', '::text, s.address_line_1, s.address_line_2, s.address_line_3) AS address,
    s.postcode,
    (ad.document ->> 'inspection_date'::text) AS inspection_date,
    s.uprn,
    (ad.document ->> 'environmental_impact_potential'::text) AS environment_impact_potential,
    (ad.document ->> 'energy_consumption_current'::text) AS energy_consumption_current,
    (ad.document ->> 'energy_consumption_potential'::text) AS energy_consumption_potential,
    (ad.document ->> 'environmental_impact_current'::text) AS environment_impact_current,
    (ad.document ->> 'co2_emissions_current'::text) AS co2_emissions_current,
    (ad.document ->> 'co2_emissions_current_per_floor_area'::text) AS co2_emiss_curr_per_floor_area,
    (ad.document ->> 'co2_emissions_potential'::text) AS co2_emissions_potential,
    (ad.document ->> 'total_floor_area'::text) AS total_floor_area,
    to_char(s.registration_date, 'yyyy-mm-dd'::text) AS lodgement_date,
    (ad.document ->> 'report_type'::text) AS report_type,
    s.post_town AS posttown,
    to_char(((ad.document ->> 'created_at'::text))::timestamp with time zone, 'YYYY-MM-DD HH24:MI:SS'::text) AS lodgement_datetime,
    (s.current_energy_efficiency_rating)::character varying AS current_energy_efficiency,
    s.current_energy_efficiency_band AS current_energy_rating,
    (ad.document ->> 'energy_rating_potential'::text) AS potential_energy_efficiency,
    public.energy_band_calculator(((ad.document ->> 'energy_rating_potential'::text))::integer, s.assessment_type) AS potential_energy_rating,
    (ad.document ->> 'extensions_count'::text) AS extension_count,
    COALESCE((ad.document ->> 'open_fireplaces_count'::text), (ad.document ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_chimneys_count'::text), ((ad.document -> 'sap_ventilation'::text) ->> 'open_fireplaces_count'::text)) AS number_open_fireplaces,
    (ad.document ->> 'heated_room_count'::text) AS number_heated_rooms,
    (ad.document ->> 'habitable_room_count'::text) AS number_habitable_rooms,
    COALESCE((ad.document ->> 'low_energy_lighting'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_percentage'::text), (round(((public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id) / NULLIF(public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id), (0)::numeric)) * (100)::numeric)))::text, ( SELECT (round(((((sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::numeric)::double precision / NULLIF(sum(((sl.value ->> 'lighting_outlets'::text))::double precision), (0)::double precision)) * (100)::double precision)))::text AS round
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_lighting,
    COALESCE((ad.document ->> 'low_energy_fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'low_energy_fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT (sum(
                CASE
                    WHEN (((sl.value ->> 'lighting_efficacy'::text))::double precision > (65)::double precision) THEN ((sl.value ->> 'lighting_outlets'::text))::integer
                    ELSE NULL::integer
                END))::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS low_energy_fixed_lighting_outlets_count,
    (ad.document ->> 'solar_water_heating'::text) AS solar_water_heating_flag,
    public.get_lookup_value('mechanical_ventilation'::character varying, ((ad.document ->> 'mechanical_ventilation'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mechanical_ventilation,
    public.get_lookup_value('tenure'::character varying, ((ad.document ->> 'tenure'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS tenure,
    public.get_lookup_value('property_type'::character varying, ((ad.document ->> 'property_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS property_type,
    public.get_lookup_value('transaction_type'::character varying, ((ad.document ->> 'transaction_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS transaction_type,
    public.fn_construction_age_band(ad.document, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS construction_age_band,
    public.get_lookup_value('built_form'::character varying, ((ad.document ->> 'built_form'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS built_form,
        CASE
            WHEN ((s.assessment_type)::text = 'RdSAP'::text) THEN public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'meter_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
            ELSE public.get_lookup_value('energy_tariff'::character varying, (((ad.document -> 'sap_energy_source'::text) ->> 'electricity_tariff'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying)
        END AS energy_tariff,
    public.get_lookup_value('glazed_type'::character varying, ((ad.document ->> 'multiple_glazing_type'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_type,
    public.get_lookup_value('glazed_area'::character varying, ((ad.document ->> 'glazed_area'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS glazed_area,
    public.get_lookup_value('heat_loss_corridor'::character varying, (((ad.document -> 'sap_flat_details'::text) ->> 'heat_loss_corridor'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS heat_loss_corridor,
    public.get_lookup_value('main_fuel'::character varying, (COALESCE(((ad.document -> 'sap_heating'::text) ->> 'main_fuel_type'::text), ((((ad.document -> 'sap_heating'::text) -> 'main_heating_details'::text) -> 0) ->> 'main_fuel_type'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS main_fuel,
    COALESCE((((ad.document -> 'sap_flat_details'::text) -> 'unheated_corridor_length'::text) ->> 'value'::text), ((ad.document -> 'sap_flat_details'::text) ->> 'unheated_corridor_length'::text)) AS unheated_corridor_length,
    ((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) AS floor_level,
    COALESCE(((ad.document -> 'sap_flat_details'::text) ->> 'top_storey'::text),
        CASE
            WHEN (((ad.document -> 'sap_flat_details'::text) ->> 'level'::text) = '3'::text) THEN 'Y'::text
            ELSE 'N'::text
        END) AS flat_top_storey,
    jsonb_array_length((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text)) AS flat_storey_count,
    COALESCE(((ad.document -> 'sap_energy_source'::text) ->> 'mains_gas'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'main_gas'::text)) AS mains_gas_flag,
    COALESCE(((((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) -> 'none_or_no_details'::text) ->> 'percent_roof_area'::text), (((ad.document -> 'sap_energy_source'::text) -> 'photovoltaic_supply'::text) ->> 'percent_roof_area'::text), (ad.document ->> 'photovoltaic_supply'::text)) AS photo_supply,
    COALESCE((((ad.document -> 'sap_energy_source'::text) ->> 'wind_turbines_count'::text))::integer, jsonb_array_length(((ad.document -> 'sap_energy_source'::text) -> 'wind_turbines'::text))) AS wind_turbine_count,
    COALESCE(((ad.document -> 'lighting_cost_current'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_current'::text)) AS lighting_cost_current,
    COALESCE(((ad.document -> 'lighting_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'lighting_cost_potential'::text)) AS lighting_cost_potential,
    COALESCE(((ad.document -> 'heating_cost_current'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_current'::text)) AS heating_cost_current,
    COALESCE(((ad.document -> 'heating_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'heating_cost_potential'::text)) AS heating_cost_potential,
    COALESCE(((ad.document -> 'hot_water_cost_current'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_current'::text)) AS hot_water_cost_current,
    COALESCE(((ad.document -> 'hot_water_cost_potential'::text) ->> 'value'::text), (ad.document ->> 'hot_water_cost_potential'::text)) AS hot_water_cost_potential,
    COALESCE((ad.document ->> 'multiple_glazed_percentage'::text), (ad.document ->> 'multiple_glazed_proportion'::text)) AS multi_glaze_proportion,
    public.fn_clean_description((COALESCE((((ad.document -> 'hot_water'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'hot_water'::text) ->> 'description'::text)))::character varying) AS hotwater_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'hot_water'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS hot_water_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'floors'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'floors'::text) -> 0) ->> 'description'::text)))::character varying) AS floor_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'floors'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS floor_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'roofs'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'roofs'::text) -> 0) ->> 'description'::text)))::character varying) AS roof_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'roofs'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS roof_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'walls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'walls'::text) -> 0) ->> 'description'::text)))::character varying) AS walls_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'walls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS walls_env_eff,
    public.fn_clean_description((COALESCE(((ad.document -> 'window'::text) ->> 'description'::text), (((ad.document -> 'window'::text) -> 0) ->> 'description'::text), ((ad.document -> 'windows'::text) ->> 'description'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'description'::text)))::character varying) AS windows_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'energy_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'energy_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'energy_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (COALESCE(((ad.document -> 'window'::text) ->> 'environmental_efficiency_rating'::text), ((ad.document -> 'windows'::text) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'window'::text) -> 0) ->> 'environmental_efficiency_rating'::text), (((ad.document -> 'windows'::text) -> 0) ->> 'environmental_efficiency_rating'::text)))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS windows_env_eff,
    COALESCE((((ad.document -> 'secondary_heating'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'secondary_heating'::text) ->> 'description'::text)) AS secondheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'secondary_heating'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS sheating_env_eff,
    ( SELECT public.fn_clean_description((COALESCE(string_agg(((mh.value -> 'description'::text) ->> 'value'::text), ', '::text), string_agg((mh.value ->> 'description'::text), ', '::text)))::character varying) AS mainheat_description
           FROM jsonb_array_elements((ad.document -> 'main_heating'::text)) mh(value)) AS mainheat_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheat_env_eff,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS mainheatcont_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, ((((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS mainheatc_env_eff,
    public.fn_clean_description((COALESCE((((ad.document -> 'lighting'::text) -> 'description'::text) ->> 'value'::text), ((ad.document -> 'lighting'::text) ->> 'description'::text)))::character varying) AS lighting_description,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'energy_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_energy_eff,
    public.get_lookup_value('energy_efficiency_rating'::character varying, (((ad.document -> 'lighting'::text) ->> 'environmental_efficiency_rating'::text))::character varying, s.assessment_type, ((ad.document ->> 'schema_type'::text))::character varying) AS lighting_env_eff,
    COALESCE((ad.document ->> 'fixed_lighting_outlets_count'::text), ((ad.document -> 'sap_energy_source'::text) ->> 'fixed_lighting_outlets_count'::text), (public.sum_attribute_values((ARRAY['cfl_fixed_lighting_bulbs_count'::text, 'led_fixed_lighting_bulbs_count'::text, 'low_energy_fixed_lighting_bulbs_count'::text, 'incandescent_fixed_lighting_bulbs_count'::text])::character varying[], ad.assessment_id))::text, ( SELECT ((sum(COALESCE(((sl.value ->> 'lighting_outlets'::text))::integer, 0)))::integer)::text AS sum
           FROM jsonb_array_elements(((ad.document -> 'sap_lighting'::text) -> 0)) sl(value))) AS fixed_lighting_outlets_count,
    COALESCE(((((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) -> 'room_height'::text) ->> 'value'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'storey_height'::text), (((ad.document -> 'sap_building_parts'::text) -> 0) ->> 'room_height'::text), (((((ad.document -> 'sap_building_parts'::text) -> 0) -> 'sap_floor_dimensions'::text) -> 0) ->> 'room_height'::text)) AS floor_height,
    public.fn_clean_description((COALESCE(((((ad.document -> 'main_heating_controls'::text) -> 0) -> 'description'::text) ->> 'value'::text), (((ad.document -> 'main_heating_controls'::text) -> 0) ->> 'description'::text)))::character varying) AS main_heating_controls,
    ons.local_authority_code AS local_authority,
    s.council AS local_authority_label,
    s.constituency AS constituency_label,
    os_p.area_code AS constituency,
    co.country_name AS country,
    ons.region_code AS region,
    public.fn_uprn_source(((ad.document ->> 'assessment_address_id'::text))::character varying, ad.matched_uprn) AS uprn_source
   FROM ((((((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN ( VALUES ('SAP'::text), ('RdSAP'::text)) vals(t) ON (((s.assessment_type)::text = vals.t)))
     JOIN public.assessments_country_ids aci ON (((ad.assessment_id)::text = (aci.assessment_id)::text)))
     JOIN public.countries co ON ((aci.country_id = co.country_id)))
     LEFT JOIN public.ons_postcode_directory ons ON (((s.postcode)::text = (ons.postcode)::text)))
     LEFT JOIN public.ons_postcode_directory_names os_p ON (((ons.westminster_parliamentary_constituency_code)::text = (os_p.area_code)::text)))
  WHERE ((((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])) AND ((s.created_at)::date = (CURRENT_DATE - 1))) OR (EXISTS ( SELECT l.assessment_id,
            l.event_type,
            l."timestamp",
            l.id
           FROM public.audit_logs l
          WHERE (((s.assessment_id)::text = (l.assessment_id)::text) AND ((l.event_type)::text = 'address_id_updated'::text) AND ((l."timestamp")::date = (CURRENT_DATE - 1))))));


--
-- Name: vw_export_documents_2008; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2008 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2008)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2009; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2009 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2009)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2010; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2010 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2010)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2011; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2011 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2011)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2012; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2012 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2012)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2013; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2013 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2013)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2014; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2014 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2014)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2015; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2015 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2015)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2016; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2016 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2016)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2017; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2017 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2017)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2018; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2018 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2018)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2019; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2019 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2019)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2020; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2020 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2020)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2021; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2021 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2021)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2022; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2022 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2022)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2023; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2023 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2023)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2024; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2024 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2024)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2025; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2025 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2025)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_export_documents_2026; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_export_documents_2026 AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((EXTRACT(year FROM s.registration_date) = (2026)::numeric) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_json_documents_yesterday; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_json_documents_yesterday AS
 SELECT ad.assessment_id AS certificate_number,
    public.fn_export_json_document(ad.document, ad.matched_uprn) AS document,
    ad.warehouse_created_at,
    ad.updated_at,
    s.assessment_type,
    (EXTRACT(year FROM s.registration_date))::integer AS year
   FROM ((public.assessment_documents ad
     JOIN public.assessment_search s ON (((s.assessment_id)::text = (ad.assessment_id)::text)))
     JOIN public.countries co ON ((s.country_id = co.country_id)))
  WHERE ((((ad.warehouse_created_at)::date = (CURRENT_DATE - 1)) OR ((ad.updated_at)::date = (CURRENT_DATE - 1))) AND ((co.country_code)::text = ANY ((ARRAY['EAW'::character varying, 'ENG'::character varying, 'WLS'::character varying])::text[])));


--
-- Name: vw_open_data_export; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_open_data_export AS
 SELECT assessment_id,
    address1,
    address2,
    address3,
    building_reference_number,
    built_form,
    co2_emiss_curr_per_floor_area,
    co2_emissions_current,
    co2_emissions_potential,
    construction_age_band,
    current_energy_efficiency,
    current_energy_rating,
    energy_consumption_current,
    energy_consumption_potential,
    energy_tariff,
    environment_impact_current,
    environment_impact_potential,
    extension_count,
    fixed_lighting_outlets_count,
    flat_storey_count,
    flat_top_storey,
    floor_description,
    floor_energy_eff,
    floor_env_eff,
    floor_height,
    floor_level,
    glazed_area,
    glazed_type,
    heat_loss_corridor,
    heating_cost_current,
    heating_cost_potential,
    hot_water_cost_current,
    hot_water_cost_potential,
    hot_water_energy_eff,
    hot_water_env_eff,
    hotwater_description,
    inspection_date,
    lighting_cost_current,
    lighting_cost_potential,
    lighting_description,
    lighting_energy_eff,
    lighting_env_eff,
    lodgement_date,
    lodgement_datetime,
    low_energy_fixed_lighting_outlets_count,
    low_energy_lighting,
    main_fuel,
    mainheat_description,
    mainheat_energy_eff,
    mainheat_env_eff,
    mainheatc_energy_eff,
    mainheatc_env_eff,
    mainheatcont_description,
    mains_gas_flag,
    mechanical_ventilation,
    multi_glaze_proportion,
    number_habitable_rooms,
    number_heated_rooms,
    number_open_fireplaces,
    photo_supply,
    postcode,
    posttown,
    potential_energy_efficiency,
    potential_energy_rating,
    property_type,
    report_type,
    roof_description,
    roof_energy_eff,
    roof_env_eff,
    secondheat_description,
    sheating_energy_eff,
    sheating_env_eff,
    solar_water_heating_flag,
    tenure,
    total_floor_area,
    transaction_type,
    unheated_corridor_length,
    walls_description,
    walls_energy_eff,
    walls_env_eff,
    wind_turbine_count,
    windows_description,
    windows_energy_eff,
    windows_env_eff
   FROM public.crosstab('
              SELECT  av.assessment_id, a.attribute_name, av.attribute_value
              FROM assessment_attribute_values av
              JOIN assessment_attributes a ON av.attribute_id = a.attribute_id
              JOIN (SELECT  assessment_id FROM assessment_attributes aa
                         JOIN assessment_attribute_values aav on aa.attribute_id = aav.attribute_id
                         WHERE aa.attribute_id = 76 AND aav.attribute_value IN (''RdSAP'', ''SAP'')
                          GROUP BY assessment_id) w ON W.assessment_Id = av.assessment_id
              WHERE a.attribute_name IN (''address1'',''address2'',''address3'',''building_reference_number'',''built_form'',''co2_emiss_curr_per_floor_area'',''co2_emissions_current'',''co2_emissions_potential'',''construction_age_band'',''current_energy_efficiency'',''current_energy_rating'',''energy_consumption_current'',''energy_consumption_potential'',''energy_tariff'',''environment_impact_current'',''environment_impact_potential'',''extension_count'',''fixed_lighting_outlets_count'',''flat_storey_count'',''flat_top_storey'',''floor_description'',''floor_energy_eff'',''floor_env_eff'',''floor_height'',''floor_level'',''glazed_area'',''glazed_type'',''heat_loss_corridor'',''heating_cost_current'',''heating_cost_potential'',''hot_water_cost_current'',''hot_water_cost_potential'',''hot_water_energy_eff'',''hot_water_env_eff'',''hotwater_description'',''inspection_date'',''lighting_cost_current'',''lighting_cost_potential'',''lighting_description'',''lighting_energy_eff'',''lighting_env_eff'',''lodgement_date'',''lodgement_datetime'',''low_energy_fixed_lighting_outlets_count'',''low_energy_lighting'',''main_fuel'',''mainheat_description'',''mainheat_energy_eff'',''mainheat_env_eff'',''mainheatc_energy_eff'',''mainheatc_env_eff'',''mainheatcont_description'',''mains_gas_flag'',''mechanical_ventilation'',''multi_glaze_proportion'',''number_habitable_rooms'',''number_heated_rooms'',''number_open_fireplaces'',''photo_supply'',''postcode'',''posttown'',''potential_energy_efficiency'',''potential_energy_rating'',''property_type'',''report_type'',''roof_description'',''roof_energy_eff'',''roof_env_eff'',''secondheat_description'',''sheating_energy_eff'',''sheating_env_eff'',''solar_water_heating_flag'',''tenure'',''total_floor_area'',''transaction_type'',''unheated_corridor_length'',''walls_description'',''walls_energy_eff'',''walls_env_eff'',''wind_turbine_count'',''windows_description'',''windows_energy_eff'',''windows_env_eff''
)
              ORDER BY assessment_id,
CASE attribute_name  WHEN ''address1'' THEN 1 WHEN ''address2'' THEN 2 WHEN ''address3'' THEN 3 WHEN ''building_reference_number'' THEN 4 WHEN ''built_form'' THEN 5 WHEN ''co2_emiss_curr_per_floor_area'' THEN 6 WHEN ''co2_emissions_current'' THEN 7 WHEN ''co2_emissions_potential'' THEN 8 WHEN ''construction_age_band'' THEN 9 WHEN ''current_energy_efficiency'' THEN 10 WHEN ''current_energy_rating'' THEN 11 WHEN ''energy_consumption_current'' THEN 12 WHEN ''energy_consumption_potential'' THEN 13 WHEN ''energy_tariff'' THEN 14 WHEN ''environment_impact_current'' THEN 15 WHEN ''environment_impact_potential'' THEN 16 WHEN ''extension_count'' THEN 17 WHEN ''fixed_lighting_outlets_count'' THEN 18 WHEN ''flat_storey_count'' THEN 19 WHEN ''flat_top_storey'' THEN 20 WHEN ''floor_description'' THEN 21 WHEN ''floor_energy_eff'' THEN 22 WHEN ''floor_env_eff'' THEN 23 WHEN ''floor_height'' THEN 24 WHEN ''floor_level'' THEN 25 WHEN ''glazed_area'' THEN 26 WHEN ''glazed_type'' THEN 27 WHEN ''heat_loss_corridor'' THEN 28 WHEN ''heating_cost_current'' THEN 29 WHEN ''heating_cost_potential'' THEN 30 WHEN ''hot_water_cost_current'' THEN 31 WHEN ''hot_water_cost_potential'' THEN 32 WHEN ''hot_water_energy_eff'' THEN 33 WHEN ''hot_water_env_eff'' THEN 34 WHEN ''hotwater_description'' THEN 35 WHEN ''inspection_date'' THEN 36 WHEN ''lighting_cost_current'' THEN 37 WHEN ''lighting_cost_potential'' THEN 38 WHEN ''lighting_description'' THEN 39 WHEN ''lighting_energy_eff'' THEN 40 WHEN ''lighting_env_eff'' THEN 41 WHEN ''lodgement_date'' THEN 42 WHEN ''lodgement_datetime'' THEN 43 WHEN ''low_energy_fixed_lighting_outlets_count'' THEN 44 WHEN ''low_energy_lighting'' THEN 45 WHEN ''main_fuel'' THEN 46 WHEN ''mainheat_description'' THEN 47 WHEN ''mainheat_energy_eff'' THEN 48 WHEN ''mainheat_env_eff'' THEN 49 WHEN ''mainheatc_energy_eff'' THEN 50 WHEN ''mainheatc_env_eff'' THEN 51 WHEN ''mainheatcont_description'' THEN 52 WHEN ''mains_gas_flag'' THEN 53 WHEN ''mechanical_ventilation'' THEN 54 WHEN ''multi_glaze_proportion'' THEN 55 WHEN ''number_habitable_rooms'' THEN 56 WHEN ''number_heated_rooms'' THEN 57 WHEN ''number_open_fireplaces'' THEN 58 WHEN ''photo_supply'' THEN 59 WHEN ''postcode'' THEN 60 WHEN ''posttown'' THEN 61 WHEN ''potential_energy_efficiency'' THEN 62 WHEN ''potential_energy_rating'' THEN 63 WHEN ''property_type'' THEN 64 WHEN ''report_type'' THEN 65 WHEN ''roof_description'' THEN 66 WHEN ''roof_energy_eff'' THEN 67 WHEN ''roof_env_eff'' THEN 68 WHEN ''secondheat_description'' THEN 69 WHEN ''sheating_energy_eff'' THEN 70 WHEN ''sheating_env_eff'' THEN 71 WHEN ''solar_water_heating_flag'' THEN 72 WHEN ''tenure'' THEN 73 WHEN ''total_floor_area'' THEN 74 WHEN ''transaction_type'' THEN 75 WHEN ''unheated_corridor_length'' THEN 76 WHEN ''walls_description'' THEN 77 WHEN ''walls_energy_eff'' THEN 78 WHEN ''walls_env_eff'' THEN 79 WHEN ''wind_turbine_count'' THEN 80 WHEN ''windows_description'' THEN 81 WHEN ''windows_energy_eff'' THEN 82 WHEN ''windows_env_eff'' THEN 83 ELSE 84 END
              '::text, ' SELECT * FROM ( values (''address1''),(''address2''),(''address3''),(''building_reference_number''),(''built_form''),(''co2_emiss_curr_per_floor_area''),(''co2_emissions_current''),(''co2_emissions_potential''),(''construction_age_band''),(''current_energy_efficiency''),(''current_energy_rating''),(''energy_consumption_current''),(''energy_consumption_potential''),(''energy_tariff''),(''environment_impact_current''),(''environment_impact_potential''),(''extension_count''),(''fixed_lighting_outlets_count''),(''flat_storey_count''),(''flat_top_storey''),(''floor_description''),(''floor_energy_eff''),(''floor_env_eff''),(''floor_height''),(''floor_level''),(''glazed_area''),(''glazed_type''),(''heat_loss_corridor''),(''heating_cost_current''),(''heating_cost_potential''),(''hot_water_cost_current''),(''hot_water_cost_potential''),(''hot_water_energy_eff''),(''hot_water_env_eff''),(''hotwater_description''),(''inspection_date''),(''lighting_cost_current''),(''lighting_cost_potential''),(''lighting_description''),(''lighting_energy_eff''),(''lighting_env_eff''),(''lodgement_date''),(''lodgement_datetime''),(''low_energy_fixed_lighting_outlets_count''),(''low_energy_lighting''),(''main_fuel''),(''mainheat_description''),(''mainheat_energy_eff''),(''mainheat_env_eff''),(''mainheatc_energy_eff''),(''mainheatc_env_eff''),(''mainheatcont_description''),(''mains_gas_flag''),(''mechanical_ventilation''),(''multi_glaze_proportion''),(''number_habitable_rooms''),(''number_heated_rooms''),(''number_open_fireplaces''),(''photo_supply''),(''postcode''),(''posttown''),(''potential_energy_efficiency''),(''potential_energy_rating''),(''property_type''),(''report_type''),(''roof_description''),(''roof_energy_eff''),(''roof_env_eff''),(''secondheat_description''),(''sheating_energy_eff''),(''sheating_env_eff''),(''solar_water_heating_flag''),(''tenure''),(''total_floor_area''),(''transaction_type''),(''unheated_corridor_length''),(''walls_description''),(''walls_energy_eff''),(''walls_env_eff''),(''wind_turbine_count''),(''windows_description''),(''windows_energy_eff''),(''windows_env_eff'')
) a '::text) virtual_columns(assessment_id character varying, address1 character varying, address2 character varying, address3 character varying, building_reference_number character varying, built_form character varying, co2_emiss_curr_per_floor_area character varying, co2_emissions_current character varying, co2_emissions_potential character varying, construction_age_band character varying, current_energy_efficiency character varying, current_energy_rating character varying, energy_consumption_current character varying, energy_consumption_potential character varying, energy_tariff character varying, environment_impact_current character varying, environment_impact_potential character varying, extension_count character varying, fixed_lighting_outlets_count character varying, flat_storey_count character varying, flat_top_storey character varying, floor_description character varying, floor_energy_eff character varying, floor_env_eff character varying, floor_height character varying, floor_level character varying, glazed_area character varying, glazed_type character varying, heat_loss_corridor character varying, heating_cost_current character varying, heating_cost_potential character varying, hot_water_cost_current character varying, hot_water_cost_potential character varying, hot_water_energy_eff character varying, hot_water_env_eff character varying, hotwater_description character varying, inspection_date character varying, lighting_cost_current character varying, lighting_cost_potential character varying, lighting_description character varying, lighting_energy_eff character varying, lighting_env_eff character varying, lodgement_date character varying, lodgement_datetime character varying, low_energy_fixed_lighting_outlets_count character varying, low_energy_lighting character varying, main_fuel character varying, mainheat_description character varying, mainheat_energy_eff character varying, mainheat_env_eff character varying, mainheatc_energy_eff character varying, mainheatc_env_eff character varying, mainheatcont_description character varying, mains_gas_flag character varying, mechanical_ventilation character varying, multi_glaze_proportion character varying, number_habitable_rooms character varying, number_heated_rooms character varying, number_open_fireplaces character varying, photo_supply character varying, postcode character varying, posttown character varying, potential_energy_efficiency character varying, potential_energy_rating character varying, property_type character varying, report_type character varying, roof_description character varying, roof_energy_eff character varying, roof_env_eff character varying, secondheat_description character varying, sheating_energy_eff character varying, sheating_env_eff character varying, solar_water_heating_flag character varying, tenure character varying, total_floor_area character varying, transaction_type character varying, unheated_corridor_length character varying, walls_description character varying, walls_energy_eff character varying, walls_env_eff character varying, wind_turbine_count character varying, windows_description character varying, windows_energy_eff character varying, windows_env_eff character varying);


--
-- Name: assessment_attribute_lookups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_lookups ALTER COLUMN id SET DEFAULT nextval('public.assessment_attribute_lookups_id_seq'::regclass);


--
-- Name: assessment_attributes attribute_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attributes ALTER COLUMN attribute_id SET DEFAULT nextval('public.assessment_attributes_attribute_id_seq'::regclass);


--
-- Name: assessment_lookups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_lookups ALTER COLUMN id SET DEFAULT nextval('public.assessment_lookups_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: ons_postcode_directory_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ons_postcode_directory_names ALTER COLUMN id SET DEFAULT nextval('public.ons_postcode_directory_names_id_seq'::regclass);


--
-- Name: ons_postcode_directory_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ons_postcode_directory_versions ALTER COLUMN id SET DEFAULT nextval('public.ons_postcode_directory_versions_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assessment_attribute_lookups assessment_attribute_lookups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_lookups
    ADD CONSTRAINT assessment_attribute_lookups_pkey PRIMARY KEY (id);


--
-- Name: assessment_attribute_values assessment_attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_values
    ADD CONSTRAINT assessment_attribute_values_pkey PRIMARY KEY (attribute_id, assessment_id);


--
-- Name: assessment_attributes assessment_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attributes
    ADD CONSTRAINT assessment_attributes_pkey PRIMARY KEY (attribute_id);


--
-- Name: assessment_documents assessment_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_documents
    ADD CONSTRAINT assessment_documents_pkey PRIMARY KEY (assessment_id);


--
-- Name: assessment_lookups assessment_lookups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_lookups
    ADD CONSTRAINT assessment_lookups_pkey PRIMARY KEY (id);


--
-- Name: assessment_search assessment_search_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_search
    ADD CONSTRAINT assessment_search_pkey PRIMARY KEY (assessment_id, registration_date);


--
-- Name: assessments_country_ids assessments_country_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments_country_ids
    ADD CONSTRAINT assessments_country_ids_pkey PRIMARY KEY (assessment_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: commercial_reports commercial_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commercial_reports
    ADD CONSTRAINT commercial_reports_pkey PRIMARY KEY (assessment_id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: audit_logs idx_audit_log_rrn_event; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT idx_audit_log_rrn_event UNIQUE (assessment_id, event_type);


--
-- Name: ons_postcode_directory_names ons_postcode_directory_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ons_postcode_directory_names
    ADD CONSTRAINT ons_postcode_directory_names_pkey PRIMARY KEY (id);


--
-- Name: ons_postcode_directory ons_postcode_directory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ons_postcode_directory
    ADD CONSTRAINT ons_postcode_directory_pkey PRIMARY KEY (postcode);


--
-- Name: ons_postcode_directory_versions ons_postcode_directory_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ons_postcode_directory_versions
    ADD CONSTRAINT ons_postcode_directory_versions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: attribute_lookup_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX attribute_lookup_index ON public.assessment_attribute_lookups USING btree (attribute_id, lookup_id, type_of_assessment, schema_version);


--
-- Name: idx_mvw_avg_co2_emissions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_mvw_avg_co2_emissions ON public.mvw_avg_co2_emissions USING btree (id);


--
-- Name: index_assessment_attribute_lookups_on_lookup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_lookups_on_lookup_id ON public.assessment_attribute_lookups USING btree (lookup_id);


--
-- Name: index_assessment_attribute_lookups_on_schema_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_lookups_on_schema_version ON public.assessment_attribute_lookups USING btree (schema_version);


--
-- Name: index_assessment_attribute_lookups_on_type_of_assessment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_lookups_on_type_of_assessment ON public.assessment_attribute_lookups USING btree (type_of_assessment);


--
-- Name: index_assessment_attribute_values_on_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_values_on_assessment_id ON public.assessment_attribute_values USING btree (assessment_id);


--
-- Name: index_assessment_attribute_values_on_attribute_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_values_on_attribute_id ON public.assessment_attribute_values USING btree (attribute_id);


--
-- Name: index_assessment_attribute_values_on_attribute_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attribute_values_on_attribute_value ON public.assessment_attribute_values USING btree (attribute_value);


--
-- Name: index_assessment_attributes_on_attribute_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attributes_on_attribute_name ON public.assessment_attributes USING btree (attribute_name);


--
-- Name: index_assessment_attributes_on_parent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_attributes_on_parent_name ON public.assessment_attributes USING btree (parent_name);


--
-- Name: index_assessment_documents_on_warehouse_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_documents_on_warehouse_created_at ON public.assessment_documents USING btree (((warehouse_created_at)::date));


--
-- Name: index_assessment_id_attribute_id_on_aav; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assessment_id_attribute_id_on_aav ON public.assessment_attribute_values USING btree (assessment_id, attribute_id);


--
-- Name: index_assessment_lookups_on_lookup_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_lookups_on_lookup_key ON public.assessment_lookups USING btree (lookup_key);


--
-- Name: index_assessment_lookups_on_lookup_key_and_lookup_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assessment_lookups_on_lookup_key_and_lookup_value ON public.assessment_lookups USING btree (lookup_key, lookup_value);


--
-- Name: index_assessment_lookups_on_lookup_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_lookups_on_lookup_value ON public.assessment_lookups USING btree (lookup_value);


--
-- Name: index_assessment_search_on_address_trigram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_address_trigram ON public.assessment_search USING gin (address public.gin_trgm_ops);


--
-- Name: index_assessment_search_on_assessment_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_assessment_address_id ON public.assessment_search USING btree (assessment_address_id);


--
-- Name: index_assessment_search_on_assessment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_assessment_type ON public.assessment_search USING btree (assessment_type);


--
-- Name: index_assessment_search_on_constituency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_constituency ON public.assessment_search USING btree (constituency);


--
-- Name: index_assessment_search_on_council; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_council ON public.assessment_search USING btree (council);


--
-- Name: index_assessment_search_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_created_at ON public.assessment_search USING btree (created_at);


--
-- Name: index_assessment_search_on_current_energy_efficiency_band; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_current_energy_efficiency_band ON public.assessment_search USING btree (current_energy_efficiency_band);


--
-- Name: index_assessment_search_on_postcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_postcode ON public.assessment_search USING btree (postcode);


--
-- Name: index_assessment_search_on_registration_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_registration_date ON public.assessment_search USING btree (registration_date);


--
-- Name: index_assessment_search_on_uprn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessment_search_on_uprn ON public.assessment_search USING btree (uprn);


--
-- Name: index_assessments_country_ids_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_country_ids_on_country_id ON public.assessments_country_ids USING btree (country_id);


--
-- Name: index_audit_logs_on_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audit_logs_on_timestamp ON public.audit_logs USING btree ("timestamp");


--
-- Name: index_commercial_reports_on_related_rrn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_commercial_reports_on_related_rrn ON public.commercial_reports USING btree (related_rrn);


--
-- Name: index_document_assessment_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_assessment_type ON public.assessment_documents USING btree (((document ->> 'assessment_type'::text)));


--
-- Name: index_document_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_created_at ON public.assessment_documents USING btree (((document ->> 'created_at'::text)));


--
-- Name: index_document_postcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_postcode ON public.assessment_documents USING btree (((document ->> 'postcode'::text)));


--
-- Name: index_document_registration_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_registration_date ON public.assessment_documents USING btree (((document ->> 'registration_date'::text)));


--
-- Name: index_document_schema_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_document_schema_type ON public.assessment_documents USING btree (((document ->> 'schema_type'::text)));


--
-- Name: index_ons_postcode_directory_names_on_area_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_names_on_area_code ON public.ons_postcode_directory_names USING btree (area_code);


--
-- Name: index_ons_postcode_directory_names_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_names_on_name ON public.ons_postcode_directory_names USING btree (name);


--
-- Name: index_ons_postcode_directory_names_on_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_names_on_type_code ON public.ons_postcode_directory_names USING btree (type_code);


--
-- Name: index_ons_postcode_directory_on_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_on_country_code ON public.ons_postcode_directory USING btree (country_code);


--
-- Name: index_ons_postcode_directory_on_local_authority_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_on_local_authority_code ON public.ons_postcode_directory USING btree (local_authority_code);


--
-- Name: index_ons_postcode_directory_on_region_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_on_region_code ON public.ons_postcode_directory USING btree (region_code);


--
-- Name: index_ons_postcode_directory_on_wpcc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ons_postcode_directory_on_wpcc ON public.ons_postcode_directory USING btree (westminster_parliamentary_constituency_code);


--
-- Name: uniq_area_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uniq_area_code ON public.ons_postcode_directory_names USING btree (area_code);


--
-- Name: assessment_attribute_lookups fk_rails_05eeb5a861; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_lookups
    ADD CONSTRAINT fk_rails_05eeb5a861 FOREIGN KEY (attribute_id) REFERENCES public.assessment_attributes(attribute_id);


--
-- Name: assessment_attribute_values fk_rails_374e745075; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_values
    ADD CONSTRAINT fk_rails_374e745075 FOREIGN KEY (attribute_id) REFERENCES public.assessment_attributes(attribute_id);


--
-- Name: assessment_attribute_lookups fk_rails_8177f207eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attribute_lookups
    ADD CONSTRAINT fk_rails_8177f207eb FOREIGN KEY (lookup_id) REFERENCES public.assessment_lookups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260730155519'),
('20260730092600'),
('20260729092502'),
('20260715154557'),
('20260715123025'),
('20260714160247'),
('20260714112924'),
('20260713110747'),
('20260707201507'),
('20260706160843'),
('20260703142716'),
('20260623151646'),
('20260602101941'),
('20260520144308'),
('20260427164008'),
('20260427144351'),
('20260427120358'),
('20260424153932'),
('20260424152351'),
('20260424150238'),
('20260331145325'),
('20260331122529'),
('20260330143003'),
('20260330143001'),
('20260319154546'),
('20260318110657'),
('20260305150140'),
('20260305115408'),
('20260303103505'),
('20260218162853'),
('20260217163643'),
('20260217154400'),
('20260217143446'),
('20260217143322'),
('20260217134917'),
('20260217105913'),
('20260209101817'),
('20260209095345'),
('20260202113728'),
('20260121112739'),
('20260120123417'),
('20260106145251'),
('20260106141909'),
('20251216120349'),
('20251201114949'),
('20251125112816'),
('20251119111249'),
('20251105123422'),
('20251103093256'),
('20251029134444'),
('20251028155152'),
('20251001100544'),
('20250926162906'),
('20250926114138'),
('20250925110510'),
('20250918132602'),
('20250918104923'),
('20250915155020'),
('20250912091520'),
('20250912090536'),
('20250910154249'),
('20250909160423'),
('20250908104158'),
('20250905145322'),
('20250904150605'),
('20250903142717'),
('20250903135838'),
('20250903134101'),
('20250902145050'),
('20250828162138'),
('20250819113832'),
('20250819112203'),
('20250815160921'),
('20250814101307'),
('20250812120019'),
('20250808120149'),
('20250808113242'),
('20250805153656'),
('20250805115758'),
('20250801151330'),
('20250730113023'),
('20250730111836'),
('20250729102219'),
('20250729100350'),
('20250729091138'),
('20250728155229'),
('20250725113836'),
('20250725111107'),
('20250718114137'),
('20250716153536'),
('20250711112524'),
('20250630091828'),
('20250626162758'),
('20250626110719'),
('20250620104721'),
('20250619112330'),
('20250618101938'),
('20250613111921'),
('20250613095308'),
('20250610144355'),
('20250516115555'),
('20250507103503'),
('20250327121801'),
('20250305142910'),
('20250305104605'),
('20250228092537'),
('20250227114215'),
('20250226142015'),
('20250224163731'),
('20250219140354'),
('20250219102223'),
('20250217105543'),
('20250212123604'),
('20250129104519'),
('20250122163501'),
('20250121120149'),
('20250103104103'),
('20250102094746'),
('20241216102125'),
('20241216101656'),
('20241128095332'),
('20241017153835'),
('20241017093511'),
('20241016141545'),
('20240912095906'),
('20240909102540'),
('20240906105903'),
('20240605145407'),
('20240605144346'),
('20240605094405'),
('20240603143411'),
('20231031112439'),
('20231030142013'),
('20231027143456'),
('20231027135710'),
('20230912142153'),
('20230809145725'),
('20230523135006'),
('20230519093622'),
('20230419155614'),
('20230113143331'),
('20221128161412'),
('20221128120647'),
('20220627143250'),
('20220113151150'),
('20211118101811'),
('20211116112101'),
('20211116111108'),
('20211108124841'),
('20211101163600'),
('20210831092100'),
('20210820123200'),
('20210802122736'),
('20210730110111'),
('20210730083249'),
('20210730083151'),
('20210730083108'),
('20210730083000'),
('20210730082314'),
('20210730082153');

