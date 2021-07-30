class AlterAssessmentAttributeValues < ActiveRecord::Migration[6.1]
  def change
    remove_column :assessment_attribute_values, :id, :bigint
    add_index :assessment_attribute_values, %i[assessment_id attribute_id], unique: true, name: "index_assessment_id_attribute_id_on_aav"
  end
end
