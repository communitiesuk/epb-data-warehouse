class AddIndexToAssessmentAttributes < ActiveRecord::Migration[6.1]
  def change
    add_index :assessment_attributes, :attribute_name
  end
end
