class Order < ApplicationRecord
  belongs_to :shop

  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items
  has_many :fulfillments
  has_one :billings_order
  has_one :billing, through: :billings_orders

  validates :shopify_id, uniqueness: true

  def self.to_csv
    CSV.generate(headers:true) do |csv|
      column_names =  ["Order Id", "First Name", "Last Name",
                       "Ship Address1", "Ship Address2", "Ship City",
                       "Ship State", "Ship Zip", "Ship Country",
                       "Ship Phone", "Email", "Quantity", "SKUs Info (SKU*Quantity)",
                       "Unit Price(price1,price2...)", "Date", "Remark", "Shipping Method",
                       "Tracking No.", "Fulfil Fee$", "Product Name", "Color", "Size"]
      csv << column_names

      all.each do |order|
        if order.shipping_method == "ePacket"
          shipping_method_code = "ePUB"
        elsif order.shipping_method == "dhl"
          shipping_method_code = "DHL"
        else
          shipping_method_code = order.shipping_method
        end
        skus = []
        order.line_items.each do |item|
          product = Product.find_by_sku(item.sku&.first(3))
          if product&.is_bundle
            product.product_ids.each do |id|
              if id[:variant_id].nil?
                skus.push("#{item.quantity} * #{Product.find(id[:product_id]).sku}")
              else
                 skus.push("#{item.quantity} * #{Variant.find(id[:variant_id]).sku}")
              end
            end
          else
            skus.push("#{item.quantity} * #{item.sku}")
          end
        end
            
        row = [order.shopify_id, order.first_name, order.last_name,
               order.ship_address1, order.ship_address2,
               order.ship_city, order.ship_state,
               order.ship_zip, order.ship_country,
               order.ship_phone, "",
               order.quantity, skus.join(","), "", order.date,
               "remark", shipping_method_code, "", "", order.product_name,
               "Color", "Size"]
        csv << row
      end
    end
  end

end
