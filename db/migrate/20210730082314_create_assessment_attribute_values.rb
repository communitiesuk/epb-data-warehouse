class CreateAssessmentAttributeValues < ActiveRecord::Migration[6.1]
  def change
    create_table :assessment_attribute_values, { primary_key: nil } do |t|
      t.integer :attribute_id, null: false, index: true
      t.string :assessment_id, null: false, index: true
      t.string :attribute_value, null: false, index: true
      t.integer :attribute_value_int, null: true
      t.float :attribute_value_float, null: true
    end

    add_foreign_key :assessment_attribute_values,
                    :assessment_attributes,
                    column: :attribute_id,
                    primary_key: :attribute_id
  end
end

