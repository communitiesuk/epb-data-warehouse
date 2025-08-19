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

ActiveRecord::Schema[7.2].define(version: 2025_08_19_112203) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
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
    t.datetime "warehouse_created_at", null: false
    t.datetime "updated_at", null: false
    t.index "((document ->> 'assessment_type'::text))", name: "index_document_assessment_type"
    t.index "((document ->> 'created_at'::text))", name: "index_document_created_at"
    t.index "((document ->> 'postcode'::text))", name: "index_document_postcode"
    t.index "((document ->> 'registration_date'::text))", name: "index_document_registration_date"
    t.index "((document ->> 'schema_type'::text))", name: "index_document_schema_type"
    t.index "((warehouse_created_at)::date)", name: "index_assessment_documents_on_warehouse_created_at"
  end

  create_table "assessment_lookups", force: :cascade do |t|
    t.string "lookup_key", null: false
    t.string "lookup_value", null: false
    t.index ["lookup_key", "lookup_value"], name: "index_assessment_lookups_on_lookup_key_and_lookup_value", unique: true
    t.index ["lookup_key"], name: "index_assessment_lookups_on_lookup_key"
    t.index ["lookup_value"], name: "index_assessment_lookups_on_lookup_value"
  end

  create_table "assessment_search", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2012m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2013m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2014m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2015m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2016m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2017m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2018m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2019m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2020m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2021m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2022m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2023m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2024m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m1", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m10", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m11", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m12", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m2", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m3", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m4", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m5", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m6", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m7", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m8", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessment_search_temp_y2025m9", primary_key: ["assessment_id", "registration_date"], force: :cascade do |t|
    t.string "assessment_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "address_line_4"
    t.string "post_town", limit: 100
    t.string "postcode", limit: 10
    t.integer "current_energy_efficiency_rating"
    t.string "current_energy_efficiency_band", limit: 2
    t.string "council", limit: 40
    t.string "constituency", limit: 45
    t.string "assessment_address_id", limit: 30
    t.string "address", limit: 500
    t.timestamptz "registration_date", null: false
    t.string "assessment_type", limit: 8
    t.datetime "created_at", precision: nil
  end

  create_table "assessments_country_ids", primary_key: "assessment_id", id: :string, force: :cascade do |t|
    t.integer "country_id"
    t.index ["country_id"], name: "index_assessments_country_ids_on_country_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "assessment_id"
    t.string "event_type", null: false
    t.datetime "timestamp", null: false
    t.index ["timestamp"], name: "index_audit_logs_on_timestamp"
    t.unique_constraint ["assessment_id", "event_type"], name: "idx_audit_log_rrn_event"
  end

  create_table "countries", primary_key: "country_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "country_code"
    t.string "country_name"
    t.jsonb "address_base_country_code"
  end

  create_table "ons_postcode_directory", primary_key: "postcode", id: { type: :string, limit: 8 }, force: :cascade do |t|
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

  add_foreign_key "assessment_attribute_lookups", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
  add_foreign_key "assessment_attribute_lookups", "assessment_lookups", column: "lookup_id"
  add_foreign_key "assessment_attribute_values", "assessment_attributes", column: "attribute_id", primary_key: "attribute_id"
end
