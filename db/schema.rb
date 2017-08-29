# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170829132430) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "images", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree
  end

  create_table "options", force: :cascade do |t|
    t.string   "name"
    t.string   "values",     default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "product_id"
    t.integer  "user_id"
    t.index ["product_id"], name: "index_options_on_product_id", using: :btree
    t.index ["user_id"], name: "index_options_on_user_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "weight"
    t.float    "length"
    t.float    "height"
    t.float    "width"
    t.string   "sku"
    t.text     "desc"
    t.float    "price"
    t.float    "compare_at_price"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "shopify_id"
    t.float    "cost"
    t.text     "link"
    t.float    "epub"
    t.float    "dhl"
    t.string   "vendor",           default: "Miskre"
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain",      null: false
    t.string   "shopify_token",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "domain"
    t.integer  "user_id"
    t.boolean  "use_carrier_service"
    t.string   "carrier_service_id"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree
    t.index ["user_id"], name: "index_shops_on_user_id", using: :btree
  end

  create_table "supplies", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "shop_id"
    t.string   "shopify_product_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["product_id"], name: "index_supplies_on_product_id", using: :btree
    t.index ["shop_id"], name: "index_supplies_on_shop_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "role"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "variants", force: :cascade do |t|
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.integer  "quantity"
    t.float    "price"
    t.string   "sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "product_id"
    t.integer  "user_id"
    t.index ["product_id"], name: "index_variants_on_product_id", using: :btree
    t.index ["user_id"], name: "index_variants_on_user_id", using: :btree
  end

  add_foreign_key "options", "products"
  add_foreign_key "options", "users"
  add_foreign_key "shops", "users"
  add_foreign_key "variants", "products"
  add_foreign_key "variants", "users"
end
