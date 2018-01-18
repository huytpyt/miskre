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

ActiveRecord::Schema.define(version: 20180118075744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.string   "scope"
    t.string   "access_token"
    t.datetime "expires_at",    precision: 6
    t.string   "resource_type",               null: false
    t.integer  "resource_id",                 null: false
    t.datetime "created_at",    precision: 6, null: false
    t.datetime "updated_at",    precision: 6, null: false
    t.index ["access_token"], name: "index_access_tokens_on_access_token", unique: true, using: :btree
    t.index ["resource_type", "resource_id"], name: "index_access_tokens_on_resource_type_and_resource_id", using: :btree
  end

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "balances", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "total_amount"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "billings", force: :cascade do |t|
    t.integer  "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "billings_orders", force: :cascade do |t|
    t.integer  "billing_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer  "order_id"
    t.index ["billing_id"], name: "index_billings_orders_on_billing_id", using: :btree
    t.index ["order_id"], name: "index_billings_orders_on_order_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "categories_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_categories_products_on_category_id", using: :btree
    t.index ["product_id"], name: "index_categories_products_on_product_id", using: :btree
  end

  create_table "detail_no_handlings", force: :cascade do |t|
    t.integer  "weight_from"
    t.integer  "weight_to"
    t.float    "cost"
    t.integer  "shipping_type_id"
    t.datetime "created_at",       precision: 6, null: false
    t.datetime "updated_at",       precision: 6, null: false
    t.index ["shipping_type_id"], name: "index_detail_no_handlings_on_shipping_type_id", using: :btree
  end

  create_table "detail_shipping_types", force: :cascade do |t|
    t.float    "weight_from"
    t.float    "weight_to"
    t.float    "cost"
    t.float    "handling_fee"
    t.integer  "shipping_type_id"
    t.datetime "created_at",       precision: 6, null: false
    t.datetime "updated_at",       precision: 6, null: false
    t.index ["shipping_type_id"], name: "index_detail_shipping_types_on_shipping_type_id", using: :btree
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
    t.datetime "created_at",       precision: 6, null: false
    t.datetime "updated_at",       precision: 6, null: false
    t.string   "items"
    t.string   "shopify_order_id"
    t.index ["order_id"], name: "index_fulfillments_on_order_id", using: :btree
  end

  create_table "image_requests", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at",    precision: 6
    t.integer  "request_product_id"
    t.datetime "created_at",         precision: 6, null: false
    t.datetime "updated_at",         precision: 6, null: false
    t.index ["request_product_id"], name: "index_image_requests_on_request_product_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at",        precision: 6, null: false
    t.datetime "updated_at",        precision: 6, null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at",   precision: 6
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "invoice_type"
    t.string   "user_id"
    t.decimal  "money_amount"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.decimal  "balance"
    t.string   "memo"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "order_id"
    t.integer  "quantity"
    t.string   "sku"
    t.string   "variant_id"
    t.float    "total_discount"
    t.datetime "created_at",           precision: 6, null: false
    t.datetime "updated_at",           precision: 6, null: false
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

  create_table "nations", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "options", force: :cascade do |t|
    t.string   "name"
    t.string   "values",                   default: [],              array: true
    t.datetime "created_at", precision: 6,              null: false
    t.datetime "updated_at", precision: 6,              null: false
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
    t.datetime "date",                 precision: 6
    t.string   "remark"
    t.string   "shipping_method"
    t.string   "tracking_no"
    t.float    "fulfill_fee"
    t.text     "product_name"
    t.string   "color"
    t.string   "size"
    t.integer  "shop_id"
    t.datetime "created_at",           precision: 6,                 null: false
    t.datetime "updated_at",           precision: 6,                 null: false
    t.string   "shopify_id"
    t.string   "financial_status"
    t.string   "fulfillment_status"
    t.boolean  "paid_for_miskre",                    default: false
    t.integer  "invoice_id"
    t.integer  "request_charge_id"
    t.string   "order_name"
    t.string   "country_code"
    t.string   "tracking_number_real"
    t.index ["shop_id"], name: "index_orders_on_shop_id", using: :btree
    t.index ["shopify_id"], name: "index_orders_on_shopify_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "weight",                             default: 0
    t.float    "length",                             default: 0.0
    t.float    "height",                             default: 0.0
    t.float    "width",                              default: 0.0
    t.string   "sku"
    t.text     "desc"
    t.float    "price"
    t.float    "compare_at_price"
    t.datetime "created_at",           precision: 6,                    null: false
    t.datetime "updated_at",           precision: 6,                    null: false
    t.string   "shopify_id"
    t.float    "cost"
    t.text     "link"
    t.float    "epub"
    t.float    "dhl"
    t.string   "vendor",                             default: "Miskre"
    t.integer  "bundle_id"
    t.boolean  "is_bundle",                          default: false
    t.integer  "quantity",                           default: 0
    t.string   "product_ids"
    t.integer  "user_id"
    t.string   "product_url"
    t.integer  "fulfillable_quantity"
    t.float    "cus_cost"
    t.float    "cus_epub"
    t.float    "cus_dhl"
    t.float    "suggest_price"
    t.integer  "sale_off"
    t.boolean  "shop_owner",                         default: false
    t.integer  "shop_id"
    t.string   "resource_url"
    t.text     "vendor_detail"
    t.string   "cost_per_quantity"
    t.boolean  "approved",                           default: false
    t.index ["bundle_id"], name: "index_products_on_bundle_id", using: :btree
    t.index ["user_id"], name: "index_products_on_user_id", using: :btree
  end

  create_table "request_charges", force: :cascade do |t|
    t.integer  "user_id"
    t.decimal  "total_amount"
    t.integer  "status",       default: 0
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "request_products", force: :cascade do |t|
    t.text     "product_name"
    t.string   "link"
    t.boolean  "status",                     default: false
    t.integer  "user_id"
    t.datetime "created_at",   precision: 6,                 null: false
    t.datetime "updated_at",   precision: 6,                 null: false
    t.index ["user_id"], name: "index_request_products_on_user_id", using: :btree
  end

  create_table "resource_images", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at",   precision: 6
    t.integer  "product_id"
    t.datetime "created_at",        precision: 6, null: false
    t.datetime "updated_at",        precision: 6, null: false
    t.index ["product_id"], name: "index_resource_images_on_product_id", using: :btree
  end

  create_table "shipping_settings", force: :cascade do |t|
    t.integer  "user_shipping_type_id"
    t.float    "min_price"
    t.text     "max_price"
    t.integer  "percent"
    t.text     "packet_name"
    t.datetime "created_at",            precision: 6, null: false
    t.datetime "updated_at",            precision: 6, null: false
    t.index ["user_shipping_type_id"], name: "index_shipping_settings_on_user_shipping_type_id", using: :btree
  end

  create_table "shipping_types", force: :cascade do |t|
    t.text     "code"
    t.text     "time_range"
    t.integer  "nation_id"
    t.datetime "created_at",   precision: 6,                null: false
    t.datetime "updated_at",   precision: 6,                null: false
    t.boolean  "has_handling",               default: true
    t.index ["nation_id"], name: "index_shipping_types_on_nation_id", using: :btree
  end

  create_table "shippings", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "min_price"
    t.text     "max_price"
    t.integer  "percent_dhl"
    t.integer  "percent_epub"
    t.text     "name_dhl"
    t.text     "name_epub"
    t.datetime "created_at",   precision: 6, null: false
    t.datetime "updated_at",   precision: 6, null: false
    t.index ["user_id"], name: "index_shippings_on_user_id", using: :btree
  end

  create_table "shops", force: :cascade do |t|
    t.string   "shopify_domain",                                      null: false
    t.string   "shopify_token",                                       null: false
    t.datetime "created_at",            precision: 6
    t.datetime "updated_at",            precision: 6
    t.string   "name"
    t.string   "domain"
    t.integer  "user_id"
    t.boolean  "use_carrier_service"
    t.string   "carrier_service_id"
    t.float    "cost_rate",                           default: 4.0
    t.float    "shipping_rate",                       default: 0.8
    t.boolean  "global_setting_enable",               default: false
    t.float    "random_from",                         default: 2.25
    t.float    "random_to",                           default: 2.75
    t.string   "plan_name"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true, using: :btree
    t.index ["user_id"], name: "index_shops_on_user_id", using: :btree
  end

  create_table "supplies", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "shop_id"
    t.string   "shopify_product_id"
    t.datetime "created_at",           precision: 6,                 null: false
    t.datetime "updated_at",           precision: 6,                 null: false
    t.text     "desc"
    t.float    "price"
    t.string   "name"
    t.boolean  "original",                           default: true
    t.integer  "user_id"
    t.integer  "fulfillable_quantity"
    t.float    "epub"
    t.float    "dhl"
    t.float    "cost_epub"
    t.float    "cost_dhl"
    t.float    "compare_at_price"
    t.float    "cost"
    t.boolean  "keep_custom",                        default: false
    t.boolean  "is_deleted",                         default: false
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
    t.datetime "created_at",       precision: 6, null: false
    t.datetime "updated_at",       precision: 6, null: false
    t.index ["supply_id"], name: "index_supply_variants_on_supply_id", using: :btree
  end

  create_table "tracking_informations", force: :cascade do |t|
    t.integer  "fulfillment_id"
    t.string   "tracking_number"
    t.integer  "status",           default: 0
    t.string   "tracking_history"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "courier_name"
  end

  create_table "tracking_products", force: :cascade do |t|
    t.integer  "open"
    t.integer  "high"
    t.integer  "low"
    t.integer  "close"
    t.integer  "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_tracking_products_on_product_id", using: :btree
  end

  create_table "user_nations", force: :cascade do |t|
    t.text     "code"
    t.text     "name"
    t.integer  "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_nations_on_user_id", using: :btree
  end

  create_table "user_products", force: :cascade do |t|
    t.string   "name"
    t.integer  "weight"
    t.integer  "length"
    t.integer  "height"
    t.integer  "width"
    t.string   "sku"
    t.text     "desc"
    t.float    "price"
    t.float    "compare_at_price"
    t.integer  "quantity",                         default: 0
    t.string   "shopify_product_id"
    t.boolean  "is_request",                       default: false, null: false
    t.string   "status",                           default: ""
    t.integer  "user_id"
    t.integer  "shop_id"
    t.datetime "created_at",         precision: 6,                 null: false
    t.datetime "updated_at",         precision: 6,                 null: false
    t.float    "cost",                             default: 0.0
    t.float    "suggest_price",                    default: 0.0
    t.index ["shop_id"], name: "index_user_products_on_shop_id", using: :btree
    t.index ["user_id"], name: "index_user_products_on_user_id", using: :btree
  end

  create_table "user_shipping_types", force: :cascade do |t|
    t.integer  "user_nation_id"
    t.integer  "shipping_type_id"
    t.boolean  "active",                         default: true
    t.datetime "created_at",       precision: 6,                null: false
    t.datetime "updated_at",       precision: 6,                null: false
    t.index ["user_nation_id"], name: "index_user_shipping_types_on_user_nation_id", using: :btree
  end

  create_table "user_variants", force: :cascade do |t|
    t.string   "name"
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.integer  "quantity",                       default: 0
    t.float    "price"
    t.string   "sku"
    t.float    "compare_at_price"
    t.integer  "user_product_id"
    t.datetime "created_at",       precision: 6,             null: false
    t.datetime "updated_at",       precision: 6,             null: false
    t.index ["user_product_id"], name: "index_user_variants_on_user_product_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                default: "",    null: false
    t.string   "encrypted_password",                   default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at",    precision: 6
    t.integer  "sign_in_count",                        default: 0,     null: false
    t.datetime "current_sign_in_at",     precision: 6
    t.datetime "last_sign_in_at",        precision: 6
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",             precision: 6,                 null: false
    t.datetime "updated_at",             precision: 6,                 null: false
    t.string   "role"
    t.string   "customer_id"
    t.boolean  "is_paid",                              default: false
    t.datetime "period_end",             precision: 6
    t.integer  "parent_id"
    t.text     "reference_code"
    t.boolean  "enable_ref",                           default: false
    t.text     "name"
    t.text     "fb_link"
    t.boolean  "active",                               default: true
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "variants", force: :cascade do |t|
    t.string   "option1"
    t.string   "option2"
    t.string   "option3"
    t.integer  "quantity"
    t.float    "price",                          default: 0.0
    t.string   "sku"
    t.datetime "created_at",       precision: 6,               null: false
    t.datetime "updated_at",       precision: 6,               null: false
    t.integer  "product_id"
    t.integer  "user_id"
    t.float    "compare_at_price"
    t.string   "product_ids"
    t.index ["product_id"], name: "index_variants_on_product_id", using: :btree
    t.index ["user_id"], name: "index_variants_on_user_id", using: :btree
  end

  add_foreign_key "options", "products", name: "options_product_id_fkey"
  add_foreign_key "options", "users", name: "options_user_id_fkey"
  add_foreign_key "orders", "shops", name: "orders_shop_id_fkey"
  add_foreign_key "shipping_settings", "user_shipping_types", name: "shipping_settings_user_shipping_type_id_fkey"
  add_foreign_key "shops", "users", name: "shops_user_id_fkey"
  add_foreign_key "supplies", "users", name: "supplies_user_id_fkey"
  add_foreign_key "user_nations", "users", name: "user_nations_user_id_fkey"
  add_foreign_key "user_shipping_types", "user_nations", name: "user_shipping_types_user_nation_id_fkey"
  add_foreign_key "user_variants", "user_products", name: "user_variants_user_product_id_fkey"
  add_foreign_key "variants", "products", name: "variants_product_id_fkey"
  add_foreign_key "variants", "users", name: "variants_user_id_fkey"
end
