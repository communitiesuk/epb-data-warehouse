class AlterFunctionsSearchPath < ActiveRecord::Migration[7.0]
  def self.up
    execute " CREATE OR REPLACE FUNCTION get_lookup_value(attribute varchar, key varchar, assessmennt_type varchar, version varchar) returns character varying
    language plpgsql
as
$$
DECLARE
value varchar;
BEGIN


    SELECT DISTINCT lookup_value INTO value
    FROM public.assessment_attribute_lookups aal
    JOIN public.assessment_lookups al on aal.lookup_id = al.id
    JOIN public.assessment_attributes aa on aal.attribute_id = aa.attribute_id
    WHERE  aa.attribute_name = attribute AND al.lookup_key = key AND aal.type_of_assessment =assessmennt_type and schema_version LIKE  (version || '%');

 RETURN value;

END $$"

    execute " CREATE OR REPLACE FUNCTION get_attribute_value(attribute varchar, rrn varchar) returns character varying
    language plpgsql
    as
    $$
    DECLARE
    value varchar;
    BEGIN

      SELECT DISTINCT attribute_value INTO value
      FROM public.assessment_attribute_values aav
      JOIN public.assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN value;

      END $$;"

    execute " CREATE OR REPLACE FUNCTION get_attribute_json(attribute varchar, rrn varchar) returns jsonb
    language plpgsql
    as
    $$
    DECLARE
    data jsonb;
    BEGIN

      SELECT DISTINCT json INTO data
      FROM public.assessment_attribute_values aav
      JOIN public.assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN data;

      END $$;"
  end

  def self.down; end
end
