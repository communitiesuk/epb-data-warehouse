class CreateAssessmentsCountryIdTable < ActiveRecord::Migration[7.0]
  def up
    create_table :assessments_country_ids, id: false, if_not_exists: true do |t|
      t.string :assessment_id
      t.integer :country_id
    end
  end

  def down
    drop_table :assessments_country_ids
  end
end
