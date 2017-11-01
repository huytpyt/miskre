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

ActiveRecord::Schema.define(version: 20171101132358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billings", force: :cascade do |t|
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billings_orders", force: :cascade do |t|
    t.integer  "billing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "order_id"
    t.index ["billing_id"], name: "index_billings_orders_on_billing_id", using: :btree
    t.index ["order_id"], name: "index_billings_orders_on_order_id", using: :btree
  end

  create_table "fulfillments", force: :cascade do |t|
    t.integer  "order_id"
    t.string   "fulfillment_id"
    t.string   "status"
    t.string   "service"
    t.string   "tracking_company"
    t.string   "shipment_status"
    t.string   "tracking_number"
    t.text     "tracking_url"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "items"
    t.string   "shopify_order_id"
    t.index ["order_id"], name: "index_fulfillments_on_order_id", using: :btree
  end

  create_table "image_requests", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "request_product_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["request_product_id"], name: "index_image_requests_on_request_product_id", using: :btree
  end

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

  create_table "line_items", force: :cascade do |t|
    t.string   "product_id"
    t.integer  "order_id"
    t.integer  "quantity"
    t.string   "sku"
    t.string   "variant_id"
    t.float    "total_discount"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.float    "price"
    t.integer  "grams"
    t.string   "title"
    t.string   "name"
    t.string   "variant_title"
    t.integer  "fulfillable_quantity"
    t.string   "fulfillment_status"
    t.string   "line_item_id"
    t.index ["order_id"], name: "index_line_items_on_order_id", using: :btree
    t.index ["product_id"], name: "index_line_items_on_product_id", using: :btree
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

  create_table "orders", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "ship_address1"
    t.string   "ship_address2"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip"
    t.string   "ship_country"
    t.string   "ship_phone"
    t.string   "email"
    t.integer  "quantity"
    t.text     "skus"
    t.text     "unit_price"
    t.datetime "date"
    t.string   "remark"
    t.string   "shipping_method"
    t.string   "tracking_no"
    t.float    "fulfill_fee"
    t.text     "product_name"
    t.string   "color"
    t.string   "size"
    t.integer  "shop_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "shopify_id"
    t.string   "financial_status"
    t.string   "fulfillment_status"
    t.index ["shop_id"], name: "index_orders_on_shop_id", using: :btree
    t.index ["shopify_id"], name: "index_orders_on_shopify_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "weight",               default: 0
    t.float    "length",               default: 0.0
    t.float    "height",               default: 0.0
    t.float    "width",                default: 0.0
    t.string   "sku"
    t.text     "desc"
    t.float    "price"
    t.float    "compare_at_price"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "shopify_id"
    t.float    "cost"
    t.text     "link"
    t.float    "epub"
    t.float    "dhl"
    t.string   "vendor",               default: "Miskre"
    t.integer  "bundle_id"
    t.boolean  "is_bundle",            default: false
    t.integer  "quantity",             default: 0
    t.string   "product_ids"
    t.integer  "user_id"
    t.string   "product_url"
    t.integer  "fulfillable_quantity"
    t.float    "cus_epub"
    t.float    "cus_dhl"
    t.float    "suggest_price"
    t.float    "cus_cost"
    t.integer  "sale_off"
    t.boolean  "shop_owner",           default: false
    t.integer  "shop_id"
    t.index ["bundle_id"], name: "index_products_on_bundle_id", using: :btree
    t.index ["user_id"], name: "index_products_on_user_id", using: :btree
  end

  create_table "request_products", force: :cascade do |t|
    t.text     "product_name"
    t.string   "link"
    t.boolean  "status",       default: false
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["user_id"], name: "index_request_products_on_user_id", using: :btree
  end

  create_table "shippings", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "min_price"
    t.text     "max_price"
    t.integer  "percent_dhl"
    t.integer  "percent_epub"
    t.text     "name_dhl"
    t.text     "name_epub"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_shippings_on_user_id", using: :btree
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain",                        null: false
    t.string   "shopify_token",                         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "domain"
    t.integer  "user_id"
    t.boolean  "use_carrier_service"
    t.string   "carrier_service_id"
    t.float    "cost_rate",             default: 4.0
    t.float    "shipping_rate",         default: 0.8
    t.boolean  "global_setting_enable", default: false
    t.float    "random_from",           default: 2.25
    t.float    "random_to",             default: 2.75
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree
    t.index ["user_id"], name: "index_shops_on_user_id", using: :btree
  end

  create_table "supplies", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "shop_id"
    t.string   "shopify_product_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.text     "desc"
    t.float    "price"
    t.string   "name"
    t.boolean  "original",             default: true
    t.integer  "user_id"
    t.integer  "fulfillable_quantity"
    t.float    "epub"
    t.float    "dhl"
    t.float    "cost_epub"
    t.float    "cost_dhl"
    t.float    "compare_at_price"
    t.float    "cost"
    t.boolean  "keep_custom",          default: false
    t.index ["product_id"], name: "index_supplies_on_product_id", using: :btree
    t.index ["shop_id"], name: "index_supplies_on_shop_id", using: :btree
    t.index ["user_id"], name: "index_supplies_on_user_id", using: :btree
  end

  create_table "supply_variants", force: :cascade do |t|
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.float    "price"
    t.string   "sku"
    t.float    "compare_at_price"
    t.integer  "supply_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["supply_id"], name: "index_supply_variants_on_supply_id", using: :btree
  end

  create_table "tracking_products", force: :cascade do |t|
    t.integer  "open"
    t.integer  "high"
    t.integer  "low"
    t.integer  "close"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_tracking_products_on_product_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "role"
    t.string   "customer_id"
    t.boolean  "is_paid",                default: false
    t.datetime "period_end"
    t.integer  "parent_id"
    t.text     "reference_code"
    t.boolean  "enable_ref",             default: false
    t.text     "name"
    t.text     "fb_link"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "variants", force: :cascade do |t|
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.integer  "quantity"
    t.float    "price",            default: 0.0
    t.string   "sku"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "product_id"
    t.integer  "user_id"
    t.float    "compare_at_price"
    t.string   "product_ids"
    t.index ["product_id"], name: "index_variants_on_product_id", using: :btree
    t.index ["user_id"], name: "index_variants_on_user_id", using: :btree
  end

  add_foreign_key "options", "products"
  add_foreign_key "options", "users"
  add_foreign_key "orders", "shops"
  add_foreign_key "shops", "users"
  add_foreign_key "supplies", "users"
  add_foreign_key "variants", "products"
  add_foreign_key "variants", "users"
end
