class DropForeignkeyAssessmentAttribute < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :assessment_attribute_values, :assessment_attributes
  end
end
