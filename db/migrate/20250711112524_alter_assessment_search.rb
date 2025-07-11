class AlterAssessmentSearch < ActiveRecord::Migration[7.0]
  def self.up
    execute "ALTER TABLE assessment_search ALTER COLUMN current_energy_efficiency_band TYPE VARCHAR(2);"
  end

  def self.down; end
end
