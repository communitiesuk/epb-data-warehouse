class AddCountryIdToAssessmentSearch < ActiveRecord::Migration[8.1]
  def self.up
    add_column :assessment_search, :country_id, :bigint
  end

  def self.down
    remove_column :assessment_search, :country_id
  end
end
