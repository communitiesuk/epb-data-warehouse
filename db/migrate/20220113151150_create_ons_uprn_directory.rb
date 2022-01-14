class CreateOnsUprnDirectory < ActiveRecord::Migration[6.1]
  def self.up
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
  end

  def self.down
    remove_foreign_key :ons_uprn_directory, :ons_uprn_directory_versions, column: :version_id

    drop_table :ons_uprn_directory
    drop_table :ons_uprn_directory_versions
  end
end
