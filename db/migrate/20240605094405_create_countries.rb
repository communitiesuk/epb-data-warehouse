class CreateCountries < ActiveRecord::Migration[7.0]
  def self.up
    create_table :countries, id: false, if_not_exists: true do |t|
      t.string :country_code
      t.string :country_name
      t.jsonb :address_base_country_code
    end
  end

  def self.down
    drop_table :countries
  end
end
