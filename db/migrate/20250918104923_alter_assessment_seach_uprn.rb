class AlterAssessmentSeachUprn < ActiveRecord::Migration[7.0]
  def self.up
    add_column :assessment_search, :uprn, :bigint
    add_index :assessment_search, :uprn
  end

  def self.down; end
end
