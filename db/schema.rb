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

ActiveRecord::Schema[8.1].define(version: 2026_08_16_190125) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asset_entries", force: :cascade do |t|
    t.bigint "amount", default: 0, null: false
    t.bigint "asset_id", null: false
    t.datetime "created_at", null: false
    t.bigint "dollar_rate"
    t.bigint "snapshot_id", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_entries_on_asset_id"
    t.index ["snapshot_id", "asset_id"], name: "index_asset_entries_on_snapshot_id_and_asset_id", unique: true
    t.index ["snapshot_id"], name: "index_asset_entries_on_snapshot_id"
  end

  create_table "assets", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, null: false
    t.boolean "liquid", default: true, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["archived"], name: "index_assets_on_archived"
    t.index ["category"], name: "index_assets_on_category"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "base_currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.date "fetched_on", null: false
    t.string "quote_currency", limit: 3, null: false
    t.bigint "rate", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency", "quote_currency", "fetched_on"], name: "index_exchange_rates_on_currencies_and_date", unique: true
  end

  create_table "snapshots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.date "taken_on", null: false
    t.datetime "updated_at", null: false
    t.index ["taken_on"], name: "index_snapshots_on_taken_on", unique: true
  end

  add_foreign_key "asset_entries", "assets"
  add_foreign_key "asset_entries", "snapshots"
end
