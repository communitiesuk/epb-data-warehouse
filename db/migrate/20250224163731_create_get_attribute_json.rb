class CreateGetAttributeJson < ActiveRecord::Migration[7.0]
  def self.up
    execute " CREATE OR REPLACE FUNCTION get_attribute_json(attribute varchar, rrn varchar) returns jsonb
    language plpgsql
    as
    $$
    DECLARE
    data jsonb;
    BEGIN

      SELECT DISTINCT json INTO data
      FROM public.assessment_attribute_values aav
      JOIN assessment_attributes a ON aav.attribute_id = a.attribute_id
      WHERE a.attribute_name = attribute AND aav.assessment_id = rrn;

      RETURN data;

      END $$;"
  end

  def self.down; end
end
