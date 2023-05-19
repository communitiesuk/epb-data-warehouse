class AddMissingPks < ActiveRecord::Migration[7.0]
  def self.up
    # add composite PK to assessment_attribute_values
    execute "ALTER TABLE assessment_attribute_values ADD PRIMARY KEY (attribute_id, assessment_id)"

    # add composite PK to ons_uprn_directory
    execute "ALTER TABLE ons_uprn_directory ADD PRIMARY KEY (uprn, version_id)"
  end

  def self.down
    execute "ALTER TABLE ons_uprn_directory DROP CONSTRAINT ons_uprn_directory_pkey"

    execute "ALTER TABLE assessment_attribute_values DROP CONSTRAINT assessment_attribute_values_pkey"
  end
end
