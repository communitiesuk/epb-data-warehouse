class UpdateAttributeValueColumnToNullTrue < ActiveRecord::Migration[6.1]
  def self.up
    change_column_null :assessment_attribute_values, :attribute_value, true
  end
end
