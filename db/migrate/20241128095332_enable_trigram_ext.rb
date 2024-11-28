class EnableTrigramExt < ActiveRecord::Migration[7.0]
  def self.up
    execute "do $$
              BEGIN
              IF NOT EXISTS (SELECT * FROM  pg_extension WHERE extname = 'pg_trgm') THEN
              CREATE EXTENSION pg_trgm;
              END IF;
              END
              $$"
  end
end
