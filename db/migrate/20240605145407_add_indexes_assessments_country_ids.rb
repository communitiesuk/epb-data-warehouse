class AddIndexesAssessmentsCountryIds < ActiveRecord::Migration[7.0]
  def up
    execute("DO
$do$
BEGIN
  IF NOT EXISTS (select constraint_name from information_schema.table_constraints where table_name = 'assessments_country_ids' and constraint_type = 'PRIMARY KEY') then
  ALTER TABLE assessments_country_ids
  ADD PRIMARY KEY (assessment_id);
  end if;
      end;
  $do$")
    add_index :assessments_country_ids, :country_id
  end

  def down
    remove_index :assessments_country_ids, :assessment_id
  end
end
