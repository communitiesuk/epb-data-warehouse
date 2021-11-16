class AddIndexAssessmentAttributeLookups < ActiveRecord::Migration[6.1]
  def change
    add_index :assessment_attribute_lookups, :lookup_id
  end
end
