# frozen_string_literal: true

shared_context "with country data" do
  before(:all) do
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE countries RESTART IDENTITY CASCADE")
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      INSERT INTO countries(country_id, country_code, country_name, address_base_country_code)
      VALUES  (1, 'ENG', 'England' ,'["E"]'::jsonb),
              (2, 'WLS', 'Wales', '{}'::jsonb),
              (3, 'NIR', 'Northern Ireland', '["N"]'::jsonb),
              (4, 'EAW', 'England and Wales', '["E", "W"]'::jsonb),
              (5, 'SCT', 'Scotland', '["S"]'::jsonb),
              (42,'', 'Channel Islands', '["L"]'::jsonb),
              (7,'NR', 'Not Recorded', null)

    SQL
  end
end
