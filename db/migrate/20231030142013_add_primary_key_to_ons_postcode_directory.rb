class AddPrimaryKeyToOnsPostcodeDirectory < ActiveRecord::Migration[7.0]
  def self.up
    execute "ALTER TABLE ons_postcode_directory ADD PRIMARY KEY (postcode)"
  end

  def self.down
    execute "ALTER TABLE ons_postcode_directory DROP CONSTRAINT ons_postcode_directory_pkey"
  end
end
