class AlterCreatedAtAssessmentDocuments < ActiveRecord::Migration[7.0]
  def self.up
    execute "ALTER TABLE assessment_documents RENAME COLUMN created_at TO warehouse_created_at"
  end

  def self.down; end
end
