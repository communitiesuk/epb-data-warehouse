# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_31_092100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "assessment_attribute_lookups", force: :cascade do |t|
    t.bigint "attribute_id", null: false
    t.bigint "lookup_id", null: false
    t.string "type_of_assessment", null: false
    t.string "schema_version"
    t.index ["attribute_id", "lookup_id", "type_of_assessment", "schema_version"], name: "attribute_lookup_index", unique: true
  end

  create_table "assessment_attribute_values", id: false, force: :cascade do |t|
    t.bigint "attribute_id", null: false
    t.string "assessment_id", null: false
    t.string "attribute_value", null: false
    t.integer "attribute_value_int"
    t.float "attribute_value_float"
    t.index ["assessment_id", "attribute_id"], name: "index_assessment_id_attribute_id_on_aav", unique: true
    t.index ["assessment_id"], name: "index_assessment_attribute_values_on_assessment_id"
    t.index ["attribute_id"], name: "index_assessment_attribute_values_on_attribute_id"
    t.index ["attribute_value"], name: "index_assessment_attribute_values_on_attribute_value"
  end

  create_table "assessment_attributes", primary_key: "attribute_id", force: :cascade do |t|
    t.string "attribute_name", null: false
    t.string "parent_name"
    t.index ["attribute_name"], name: "index_assessment_attributes_on_attribute_name"
    t.index ["parent_name"], name: "index_assessment_attributes_on_parent_name"
  end

  create_table "assessment_lookups", force: :cascade do |t|
    t.string "lookup_key", null: false
    t.string "lookup_value", null: false
    t.index ["lookup_key", "lookup_value"], name: "index_assessment_lookups_on_lookup_key_and_lookup_value", unique: true
    t.index ["lookup_key"], name: "index_assessment_lookups_on_lookup_key"
    t.index ["lookup_value"], name: "index_assessment_lookups_on_lookup_value"
  end

  add_foreign_key "assessment_attribute_lookups", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
  add_foreign_key "assessment_attribute_lookups", "assessment_lookups", column: "lookup_id"
  add_foreign_key "assessment_attribute_values", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
end
