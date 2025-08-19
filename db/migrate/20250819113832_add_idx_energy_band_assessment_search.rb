class AddIdxEnergyBandAssessmentSearch < ActiveRecord::Migration[7.0]
  def self.up
    remove_index :assessment_search, :current_energy_efficiency_rating, if_exists: true
    add_index :assessment_search, :current_energy_efficiency_band
  end

  def self.down; end
end
