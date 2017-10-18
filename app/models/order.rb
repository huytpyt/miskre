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
            
        row = [order.shopify_id, order.first_name, order.last_name,
               order.ship_address1, order.ship_address2,
               order.ship_city, order.ship_state,
               order.ship_zip, order.ship_country,
               order.ship_phone, "",
               order.quantity, order.skus, "", order.date,
               "remark", shipping_method_code, "", "", order.product_name,
               "Color", "Size"]
        csv << row
      end
    end
  end

end
