class AddConstraintOnsPostcodeDirectoryNames < ActiveRecord::Migration[8.1]
  def self.up
    add_index :ons_postcode_directory_names, [:area_code], unique: true, name: "uniq_area_code"
  end

  def self.down; end
end
