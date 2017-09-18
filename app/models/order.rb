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
      column_names =  ["OrderId", "First Name", "Last Name",
                       "Ship Address1", "Ship Address2", "Ship City",
                       "Ship State", "Ship Zip", "Ship Country",
                       "Ship Phone", "Email", "Quantity", "SKUs Info",
                       "Unit Price", "Date", "Remark", "Shipping Method",
                       "Tracking No.", "Fulfill Fee", "Product Name",
                       "Color", "Size"]
      csv << column_names

      all.each do |order|
        row = [order.shopify_id, order.first_name, order.last_name,
               order.ship_address1, order.ship_address2,
               order.ship_city, order.ship_state,
               order.ship_zip, order.ship_country,
               order.ship_phone, order.email,
               order.quantity, order.skus, order.unit_price, order.date,
               "remark", order.shipping_method, "0", "0", order.product_name,
               "Color", "Size"]
        csv << row
      end
    end
  end

end
