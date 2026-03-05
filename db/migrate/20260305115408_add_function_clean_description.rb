class AddFunctionCleanDescription < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
       CREATE OR REPLACE FUNCTION fn_clean_description(description character varying) RETURNS varchar
                language plpgsql
                as
                $$
                  DECLARE
                  data varchar;

                  BEGIN

                   PERFORM description::jsonb;
                        return (description)::jsonb ->> 'value';
                  EXCEPTION WHEN others THEN
                      return regexp_replace(description::varchar, '{.*', '', 'g');
                  END

      $$
    SQL
  end

  def self.up
    execute sql
  end

  def self.down; end
end
