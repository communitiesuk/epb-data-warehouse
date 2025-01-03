class AddIndicesDomesticSearch < ActiveRecord::Migration[7.0]
  def self.up
    add_index :mvw_domestic_search, :lodgement_date
    add_index :mvw_domestic_search, :local_authority_label
  end

  def self.down; end
end
