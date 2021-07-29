class CreateAssessmentAttributes < ActiveRecord::Migration[6.1]
  def change
    create_table :assessment_attributes, { primary_key: :attribute_id } do |t|
      t.string :attribute_name, null: false
    end
  end
end
