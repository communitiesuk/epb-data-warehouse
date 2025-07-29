class RemoveMvwDomesticSearchIndex < ActiveRecord::Migration[7.0]
  def self.up
    remove_index :mvw_domestic_search, :rrn
    remove_index :mvw_domestic_search, :lodgement_date
    remove_index :mvw_domestic_search, :local_authority_label
    remove_index :mvw_domestic_search, :constituency_label
    remove_index :mvw_domestic_search, :current_energy_rating
  end

  def self.down; end
end
