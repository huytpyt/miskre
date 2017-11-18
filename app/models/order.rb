# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  first_name         :string
#  last_name          :string
#  ship_address1      :string
#  ship_address2      :string
#  ship_city          :string
#  ship_state         :string
#  ship_zip           :string
#  ship_country       :string
#  ship_phone         :string
#  email              :string
#  quantity           :integer
#  skus               :text
#  unit_price         :text
#  date               :datetime
#  remark             :string
#  shipping_method    :string
#  tracking_no        :string
#  fulfill_fee        :float
#  product_name       :text
#  color              :string
#  size               :string
#  shop_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  shopify_id         :string
#  financial_status   :string
#  fulfillment_status :string
#
# Indexes
#
#  index_orders_on_shop_id     (shop_id)
#  index_orders_on_shopify_id  (shopify_id)
#
# Foreign Keys
#
#  fk_rails_...  (shop_id => shops.id)
#

class Order < ApplicationRecord
  belongs_to :shop

  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items
  has_many :fulfillments
  has_one :billings_order
  has_one :billing, through: :billings_orders

  validates :shopify_id, uniqueness: true

  def self.to_xls
    CSV.generate(headers:true) do |csv|
      column_names =  ["Order Id", "First Name", "Last Name",
                       "Ship Address1", "Ship Address2", "Ship City",
                       "Ship State", "Ship Zip", "Ship Country",
                       "Ship Phone", "Email", "Quantity", "SKUs Info (SKU*Quantity)",
                       "Unit Price(price1,price2...)", "Date", "Remark", "Shipping Method",
                       "Tracking No.", "Fulfil Fee$", "Product Name", "Color", "Size"]
      csv << column_names
      all.each do |order|
        skus = []
        skus_array = order.skus.split(",")
        skus_array.each do |item|
          sku_item = item.split("*")
          sku = sku_item[0].strip
          quantity = sku_item[1]
          product = Product.find_by_sku(sku&.first(3))
          if product&.is_bundle
            if product.variants.present?
              variant = Variant.find_by_sku sku
              variant.product_ids.each do |id|
                if id[:variant_id].nil?
                  skus.push("#{Product.find(id[:product_id]).sku} * #{quantity}") 
                else
                   skus.push("#{Variant.find(id[:variant_id]).sku} * #{quantity}")
                end
              end
            else
              product.product_ids.each do |id|
                if id[:variant_id].nil?
                  skus.push("#{Product.find(id[:product_id]).sku} * #{quantity}") 
                else
                   skus.push("#{Variant.find(id[:variant_id]).sku} * #{quantity}")
                end
              end
            end
          else
            skus.push("#{sku} * #{quantity}")
          end
        end
            
        row = [order.shopify_id, order.first_name, order.last_name,
               order.ship_address1, order.ship_address2,
               order.ship_city, order.ship_state,
               order.ship_zip, order.ship_country,
               order.ship_phone, "",
               order.quantity, skus.join(","), "", order.date,
               "remark", order.shipping_method, "", "", order.product_name,
               "Color", "Size"]
        csv << row
      end
    end
  end

end
