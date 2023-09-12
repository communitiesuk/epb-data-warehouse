class TrimOnsPostcodes < ActiveRecord::Migration[7.0]
  def self.up
    execute "UPDATE ons_uprn_directory SET postcode = TRIM(postcode)"
  end

end
