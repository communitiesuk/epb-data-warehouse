class AddAdditionalIndexAssessmentAttributeLookups < ActiveRecord::Migration[6.1]
  def change
    add_index :assessment_attribute_lookups, :schema_version
    add_index :assessment_attribute_lookups, :type_of_assessment
  end
end
