class NormalizeEnergyConsumptionValues < ActiveRecord::Migration
  def self.up
    # normalize the values for energy_consumption_current and energy_consumption_potential so they are simple values not objects
    # in JSONB store
    execute "UPDATE assessment_documents SET document=jsonb_set(document, '{energy_consumption_current}', document -> 'energy_consumption_current' -> 'value') WHERE document -> 'energy_consumption_current' ? 'value'"
    execute "UPDATE assessment_documents SET document=jsonb_set(document, '{energy_consumption_potential}', document -> 'energy_consumption_potential' -> 'value') WHERE document -> 'energy_consumption_potential' ? 'value'"
    # in EAV store
    execute "UPDATE assessment_attribute_values SET attribute_value = (json -> 'value')::varchar, attribute_value_int = (json -> 'value')::integer, attribute_value_float = (json -> 'value')::float, json = NULL WHERE json IS NOT NULL AND attribute_id IN (SELECT attribute_id FROM assessment_attributes WHERE attribute_name IN ('energy_consumption_current', 'energy_consumption_potential'))"
  end

  def self.down
    # nothing to do as we wouldn't want to unnormalize these values, and up action is idempotent here
  end
end
