class DropOnsUprnDirectoryTables < ActiveRecord::Migration[7.0]
  def self.up
    remove_foreign_key :ons_uprn_directory_names, :ons_uprn_directory_versions, column: :version_id
    remove_foreign_key :ons_uprn_directory, :ons_uprn_directory_versions, column: :version_id

    drop_table :ons_uprn_directory
    drop_table :ons_uprn_directory_names
    drop_table :ons_uprn_directory_versions
  end

  def self.down
    create_table :ons_uprn_directory_versions, id: :serial do |t|
      t.string :version_month, null: false, limit: 7, index: { unique: true }
    end

    create_table :ons_uprn_directory, id: false do |t|
      t.string :uprn, null: false, limit: 17, index: true
      t.string :postcode, null: false, limit: 8
      t.jsonb  :areas, null: false
      t.integer :version_id, null: false
    end

    add_foreign_key :ons_uprn_directory, :ons_uprn_directory_versions, column: :version_id

    create_table :ons_uprn_directory_names do |t|
      t.string  :area_code, null: false, index: true
      t.string  :name, null: false, index: true
      t.string  :type, null: false
      t.string  :type_code, null: false, index: true
      t.integer :version_id, null: false
    end

    add_foreign_key :ons_uprn_directory_names, :ons_uprn_directory_versions, column: :version_id
  end
end
