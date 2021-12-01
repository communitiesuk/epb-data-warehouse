class AddConstraintAssessmentAttributes < ActiveRecord::Migration[6.1]
  def change
    add_index :assessment_attributes, %i[attribute_name parent_name],
              unique: true,
              name: "index_assessment_attribute_group"
  end
end
