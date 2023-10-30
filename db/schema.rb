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

ActiveRecord::Schema[7.0].define(version: 2023_10_27_143456) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "tablefunc"

  create_table "assessment_attribute_lookups", force: :cascade do |t|
    t.bigint "attribute_id", null: false
    t.bigint "lookup_id", null: false
    t.string "type_of_assessment", null: false
    t.string "schema_version"
    t.index ["attribute_id", "lookup_id", "type_of_assessment", "schema_version"], name: "attribute_lookup_index", unique: true
    t.index ["lookup_id"], name: "index_assessment_attribute_lookups_on_lookup_id"
    t.index ["schema_version"], name: "index_assessment_attribute_lookups_on_schema_version"
    t.index ["type_of_assessment"], name: "index_assessment_attribute_lookups_on_type_of_assessment"
  end

  create_table "assessment_attribute_values", primary_key: ["attribute_id", "assessment_id"], force: :cascade do |t|
    t.bigint "attribute_id", null: false
    t.string "assessment_id", null: false
    t.string "attribute_value"
    t.integer "attribute_value_int"
    t.float "attribute_value_float"
    t.jsonb "json"
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

  create_table "assessment_documents", primary_key: "assessment_id", id: :string, force: :cascade do |t|
    t.jsonb "document", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((document ->> 'assessment_type'::text))", name: "index_document_assessment_type"
    t.index "((document ->> 'postcode'::text))", name: "index_document_postcode"
    t.index "((document ->> 'registration_date'::text))", name: "index_document_registration_date"
    t.index "((document ->> 'schema_type'::text))", name: "index_document_schema_type"
  end

  create_table "assessment_lookups", force: :cascade do |t|
    t.string "lookup_key", null: false
    t.string "lookup_value", null: false
    t.index ["lookup_key", "lookup_value"], name: "index_assessment_lookups_on_lookup_key_and_lookup_value", unique: true
    t.index ["lookup_key"], name: "index_assessment_lookups_on_lookup_key"
    t.index ["lookup_value"], name: "index_assessment_lookups_on_lookup_value"
  end

  create_table "ons_postcode_directory", id: false, force: :cascade do |t|
    t.string "postcode", limit: 8, null: false
    t.string "country_code", limit: 9, null: false
    t.string "region_code", limit: 9, null: false
    t.string "local_authority_code", limit: 9, null: false
    t.string "westminster_parliamentary_constituency_code", limit: 9, null: false
    t.jsonb "other_areas", null: false
    t.index ["country_code"], name: "index_ons_postcode_directory_on_country_code"
    t.index ["local_authority_code"], name: "index_ons_postcode_directory_on_local_authority_code"
    t.index ["region_code"], name: "index_ons_postcode_directory_on_region_code"
    t.index ["westminster_parliamentary_constituency_code"], name: "index_ons_postcode_directory_on_wpcc"
  end

  create_table "ons_postcode_directory_names", force: :cascade do |t|
    t.string "area_code", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.string "type_code", null: false
    t.index ["area_code"], name: "index_ons_postcode_directory_names_on_area_code"
    t.index ["name"], name: "index_ons_postcode_directory_names_on_name"
    t.index ["type_code"], name: "index_ons_postcode_directory_names_on_type_code"
  end

  create_table "ons_postcode_directory_versions", id: :serial, force: :cascade do |t|
    t.string "version_month", limit: 7, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ons_uprn_directory", primary_key: ["uprn", "version_id"], force: :cascade do |t|
    t.string "uprn", limit: 17, null: false
    t.string "postcode", limit: 8, null: false
    t.jsonb "areas", null: false
    t.integer "version_id", null: false
    t.index "((areas ->> 'ctry22cd'::text))", name: "idx_ons_uprn_directory_area_country"
    t.index ["uprn"], name: "index_ons_uprn_directory_on_uprn"
  end

  create_table "ons_uprn_directory_names", force: :cascade do |t|
    t.string "area_code", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.string "type_code", null: false
    t.integer "version_id", null: false
    t.index ["area_code"], name: "index_ons_uprn_directory_names_on_area_code"
    t.index ["name"], name: "index_ons_uprn_directory_names_on_name"
    t.index ["type_code"], name: "index_ons_uprn_directory_names_on_type_code"
  end

  create_table "ons_uprn_directory_versions", id: :serial, force: :cascade do |t|
    t.string "version_month", limit: 7, null: false
    t.index ["version_month"], name: "index_ons_uprn_directory_versions_on_version_month", unique: true
  end

  add_foreign_key "assessment_attribute_lookups", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
  add_foreign_key "assessment_attribute_lookups", "assessment_lookups", column: "lookup_id"
  add_foreign_key "assessment_attribute_values", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
  add_foreign_key "ons_uprn_directory", "ons_uprn_directory_versions", column: "version_id"
  add_foreign_key "ons_uprn_directory_names", "ons_uprn_directory_versions", column: "version_id"
end
