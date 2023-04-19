class AddMainFuelEnumForSap191 < ActiveRecord::Migration[7.0]
  def self.up
    execute "INSERT INTO assessment_attribute_lookups(attribute_id, lookup_id, type_of_assessment, schema_version)
SELECT aal.attribute_id, lookup_id, type_of_assessment,'SAP-Schema-19.1.0/SAP'
FROM assessment_attribute_lookups aal
JOIN assessment_lookups al ON al.id = aal.lookup_id
JOIN assessment_attributes aa on aa.attribute_id = aal.attribute_id
WHERE schema_version = 'SAP-Schema-19.0.0/SAP'
AND attribute_name = 'main_fuel'"

    execute "INSERT INTO assessment_lookups(lookup_key, lookup_value)
VALUES (47, 'Community heating schemes: high grade heat recovered from process')"

    execute "INSERT INTO assessment_attribute_lookups(schema_version, attribute_id, lookup_id, type_of_assessment)
SELECT 'SAP-Schema-19.1.0/SAP', attribute_id, (SELECT MAX(id) FROM assessment_lookups), 'SAP'
FROM assessment_attributes
WHERE attribute_name = 'main_fuel'"

    execute "INSERT INTO assessment_lookups(lookup_key, lookup_value)
             VALUES (49, 'Community heating schemes: low grade heat recovered from process')"

    execute "UPDATE assessment_attribute_lookups
              SET lookup_id =  (SELECT MAX(id) FROM assessment_lookups)
              WHERE id = (
              SELECT aal.id FROM assessment_attribute_lookups aal
              JOIN assessment_lookups al ON al.id = aal.lookup_id
              JOIN assessment_attributes aa on aa.attribute_id = aal.attribute_id
              WHERE schema_version = 'SAP-Schema-19.1.0/SAP' AND al.lookup_key = '49'
              AND attribute_name = 'main_fuel')"
  end

  def self.down; end
end
