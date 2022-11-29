class AddOnsUprnDirectoryNamesTable < ActiveRecord::Migration[7.0]
  def self.up
    create_table :ons_uprn_directory_names do |t|
      t.string  :area_code, null: false, index: true
      t.string  :name, null: false, index: true
      t.string  :type, null: false
      t.string  :type_code, null: false, index: true
      t.integer :version_id, null: false
    end

    add_foreign_key :ons_uprn_directory_names, :ons_uprn_directory_versions, column: :version_id
  end

  def self.down
    remove_foreign_key :ons_uprn_directory_names, :ons_uprn_directory_versions, column: :version_id

    drop_table :ons_uprn_directory_names
  end
end
