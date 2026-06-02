class AddSchemaTypeToAssessmentSearch < ActiveRecord::Migration[8.1]
  def self.up
    add_column :assessment_search, :schema_type, :string, limit: 30
  end

  def self.down
    remove_column :assessment_search, :schema_type
  end
end
