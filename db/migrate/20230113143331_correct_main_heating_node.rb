class CorrectMainHeatingNode < ActiveRecord::Migration[7.0]
  def self.up
    execute "UPDATE assessment_documents SET document = document - 'main-heating' || jsonb_build_object('main_heating', document -> 'main-heating'), updated_at = NOW() WHERE document ? 'main-heating'"
    execute "UPDATE assessment_attribute_values SET attribute_id=(SELECT attribute_id FROM assessment_attributes WHERE attribute_name = 'main_heating') WHERE attribute_id=(SELECT attribute_id FROM assessment_attributes WHERE attribute_name = 'main-heating')"
  end

  def self.down
    # no down migration necessary as this is a data fix
  end
end
