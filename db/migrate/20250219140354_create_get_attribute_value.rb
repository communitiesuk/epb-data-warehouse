class CreateGetAttributeValue < ActiveRecord::Migration[7.0]
  def self.up
    execute " CREATE OR REPLACE FUNCTION get_attribute_value(attribute varchar, rrn varchar) returns character varying
    language plpgsql
    as
    $$
    DECLARE
    value varchar;
    BEGIN

      SELECT DISTINCT attribute_value INTO value
      FROM public.assessment_attribute_values aav
      JOIN assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN value;

      END $$;"
  end

  def self.down; end
end
