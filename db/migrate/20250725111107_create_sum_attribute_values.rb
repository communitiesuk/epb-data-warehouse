class CreateSumAttributeValues < ActiveRecord::Migration[7.0]
  def self.up
    execute "
      CREATE OR REPLACE FUNCTION sum_attribute_values(attribute_names VARCHAR[], assessment_id VARCHAR)
      RETURNS numeric
      LANGUAGE plpgsql
      AS $$
      DECLARE
        attribute_name VARCHAR;
        total_value NUMERIC := 0;
      BEGIN
        FOREACH attribute_name IN ARRAY attribute_names LOOP
          total_value := total_value + get_attribute_value(attribute_name, assessment_id)::numeric;
        END LOOP;
        RETURN total_value;
      END $$;
    "
  end

  def self.down; end
end
