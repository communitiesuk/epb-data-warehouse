class LookupChanges < ActiveRecord::Migration[6.1]
  def up
    rename_table :assessment_look_ups, :assessment_lookups

    change_table :assessment_lookups, id: :bigint do |t|
      t.remove :schema
      t.remove :schema_version
      t.remove :attribute_id
      t.rename :look_up_name, :lookup_key
      t.rename :look_up_value, :lookup_value
    end
    add_index :assessment_lookups, %i[lookup_key lookup_value], unique: true

    create_table :assessment_attribute_lookups do |t|
      t.bigint :attribute_id, null: false
      t.bigint :lookup_id, null: false
      t.string :type_of_assessment, null: false
      t.string :schema_version
    end
    add_index :assessment_attribute_lookups, %i[attribute_id lookup_id type_of_assessment schema_version], unique: true, name: "attribute_lookup_index"

    add_foreign_key :assessment_attribute_lookups, :assessment_lookups, column: :lookup_id
    add_foreign_key :assessment_attribute_lookups, :assessment_attributes, column: :attribute_id, primary_key: :attribute_id
  end

  def down
    remove_foreign_key :assessment_attribute_lookups, :assessment_lookups, column: :lookup_id
    remove_foreign_key :assessment_attribute_lookups, :assessment_attributes, column: :attribute_id, primary_key: :attribute_id

    remove_index :assessment_attribute_lookups, %i[attribute_id lookup_id], unique: true, name: "attribute_lookup_index"
    drop_table :assessment_attribute_lookups

    change_table :assessment_lookups do |t|
      t.string :schema, null: false
      t.string :schema_version
      t.bigint :attribute_id, null: false
      t.rename :lookup_id, :look_up_name
      t.rename :lookup_value, :look_up_value
    end

    rename_table :assessment_lookups, :assessment_look_ups
  end
end
