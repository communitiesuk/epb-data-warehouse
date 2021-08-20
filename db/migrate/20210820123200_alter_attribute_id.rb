class AlterAttributeId < ActiveRecord::Migration[6.1]
  change_column :assessment_attribute_values, :attribute_id, :bigint
  change_column :assessment_look_ups, :attribute_id, :bigint
end
