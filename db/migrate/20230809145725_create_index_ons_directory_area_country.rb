class CreateIndexOnsDirectoryAreaCountry < ActiveRecord::Migration[6.1]
  def self.up
    execute "CREATE INDEX IF NOT EXISTS idx_ons_uprn_directory_area_country ON public.ons_uprn_directory USING btree (((areas ->> 'ctry22cd'::text)))"
  end

  def self.down
    execute "DROP INDEX IF EXISTS idx_ons_uprn_directory_area_country"
  end
end
