desc "Import assessments fixture into to the dev database for testing"
task :seed_countries do
  ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE countries RESTART IDENTITY CASCADE", "SQL")

  insert_sql = <<-SQL
            INSERT INTO countries(country_id, country_code, country_name, address_base_country_code)
            VALUES (1, 'ENG', 'England', '["E"]'::jsonb),
                   (2, 'EAW', 'England and Wales', '["E", "W"]'::jsonb),
                     (3, 'UKN', 'Unknown', '{}'::jsonb),
                    (4, 'NIR', 'Northern Ireland', '["N"]'::jsonb),
                    (5, 'SCT', 'Scotland', '["S"]'::jsonb),
            (6, '', 'Channel Islands', '["L"]'::jsonb),
             (7, 'NR', 'Not Recorded', null)
            #{'  '}
  SQL
  ActiveRecord::Base.connection.exec_query(insert_sql, "SQL")
end
