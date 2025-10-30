class FixCreateSumAttributeValuesNullHandling < ActiveRecord::Migration[7.0]
  def self.up
    execute "
      CREATE OR REPLACE FUNCTION sum_attribute_values(attribute_names VARCHAR[], assessment_id VARCHAR)
      RETURNS numeric
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
    "
  end

  def self.down; end
end
