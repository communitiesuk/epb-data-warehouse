class CreateOnsPostcodeDirectory < ActiveRecord::Migration[7.0]
  def self.up
    create_table :ons_postcode_directory_versions, id: :serial do |t|
      t.string :version_month, null: false, limit: 7
      t.timestamps
    end

    create_table :ons_postcode_directory, id: false, primary_key: :postcode do |t|
      t.string :postcode, null: false, limit: 8
      t.string :country_code, null: false, limit: 9, index: true
      t.string :region_code, null: false, limit: 9, index: true
      t.string :local_authority_code, null: false, limit: 9, index: true
      t.string :westminster_parliamentary_constituency_code, null: false, limit: 9, index: { name: :index_ons_postcode_directory_on_wpcc }
      t.jsonb  :other_areas, null: false
    end
  end

  def self.down
    drop_table :ons_postcode_directory
    drop_table :ons_postcode_directory_versions
  end
end
