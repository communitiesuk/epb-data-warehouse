class CreateOnsPostcodeNamesTable < ActiveRecord::Migration[7.0]
  def self.up
    create_table :ons_postcode_directory_names do |t|
      t.string  :area_code, null: false, index: true
      t.string  :name, null: false, index: true
      t.string  :type, null: false
      t.string  :type_code, null: false, index: true
    end
  end

  def self.down
    drop_table :ons_postcode_directory_names
  end
end
