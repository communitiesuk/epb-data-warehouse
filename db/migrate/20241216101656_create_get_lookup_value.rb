class CreateGetLookupValue < ActiveRecord::Migration[7.0]
  def self.up
    execute " CREATE OR REPLACE FUNCTION get_lookup_value(attribute varchar, key varchar, assessmennt_type varchar, version varchar) returns character varying
    language plpgsql
as
$$
DECLARE
value varchar;
BEGIN


    SELECT DISTINCT lookup_value INTO value
    FROM assessment_attribute_lookups aal
    JOIN assessment_lookups al on aal.lookup_id = al.id
    JOIN public.assessment_attributes aa on aal.attribute_id = aa.attribute_id
    WHERE  aa.attribute_name = attribute AND al.lookup_key = key AND aal.type_of_assessment =assessmennt_type and schema_version LIKE  (version || '%');

 RETURN value;

END $$"
  end

  def self.down; end
end
