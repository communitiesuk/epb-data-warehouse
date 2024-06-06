class AddPkCountries < ActiveRecord::Migration[7.0]
  def self.up
    execute("ALTER TABLE countries ADD COLUMN IF NOT EXISTS country_id INTEGER;")
    execute("DO
$do$
BEGIN
IF NOT EXISTS (select constraint_name from information_schema.table_constraints where table_name = 'countries' and constraint_type = 'PRIMARY KEY') then
ALTER TABLE countries
  ADD PRIMARY KEY (country_id);
end if;
end;
$do$")
  end
end
