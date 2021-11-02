class AddJsonbColumnToAssessmentAttributesValues < ActiveRecord::Migration[6.1]
  def self.up
    change_table :assessment_attribute_values do |t|
      t.jsonb :json, null: true
    end
  end
end
