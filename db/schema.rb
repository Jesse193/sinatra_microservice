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

ActiveRecord::Schema[8.1].define(version: 2026_06_12_210418) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "markets", force: :cascade do |t|
    t.string "accepted_payment"
    t.string "address"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "fnap"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "site"
    t.string "snap_option"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "users_favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "market_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["market_id"], name: "index_users_favorites_on_market_id"
    t.index ["user_id", "market_id"], name: "index_users_favorites_on_user_id_and_market_id", unique: true
    t.index ["user_id"], name: "index_users_favorites_on_user_id"
  end

  add_foreign_key "users_favorites", "markets"
  add_foreign_key "users_favorites", "users"
end
