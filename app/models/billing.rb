class Billing < ApplicationRecord
  has_many :billings_orders, dependent: :destroy

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    if spreadsheet == false
      return nil
    end
    header = spreadsheet.row(1)
    billing = self.create(status: "pending")
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      order = Order.find_by_shopify_id row["Order Id"]
      billings_orders = BillingsOrder.find_by_order_shopify_id row["Order Id"]
      if order.present? && billings_orders.nil? && order&.fulfillments.none?
        billings_order =  billing.billings_orders.new(order_shopify_id: row["Order Id"])
        fulfillment = order.fulfillments.new({"shopify_order_id"=>row["Order Id"], "fulfillment_id"=>nil, "status"=>"success", "service"=>"manual", "tracking_company"=>row["Shipping Method"], "tracking_number"=>row["Tracking No."], "tracking_url"=>TRACKING_URL + row["Tracking No."], "items"=>order.line_items.collect {|order| {name: order.name, quantity: order.quantity}} })
        if fulfillment.save
          billings_order.save
          line_items = order.line_items.each {|line_item| line_item.update(fulfillable_quantity: 0)}
          order.update(fulfillment_status: "fulfilled")
        end
      end
    end
    unless billing.billings_orders.present?
      billing.destroy
      return nil
    else
      return billing.id
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, {})
    when ".xls" then Roo::Excel.new(file.path, {})
    when ".xlsx" then Roo::Excelx.new(file.path, {})
    else
      return false
    end
  end
  enum status: { pending: 0, paid: 1 }
end
