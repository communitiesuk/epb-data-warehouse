class AddCompositeKeyAssessmentSearch < ActiveRecord::Migration[7.0]
  def self.up
    execute "ALTER TABLE assessment_search DROP CONSTRAINT IF EXISTS assessment_search_pkey"
    execute "ALTER TABLE assessment_search add primary key (assessment_id, registration_date)"
  end

  def self.down; end
end
