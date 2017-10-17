class BillingService
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv"
      begin
        Roo::Csv.new(file.path, {})
      rescue
        return false
      end
    when ".xls"
      begin
        Roo::Excel.new(file.path, {})
      rescue
        return false
      end        
    when ".xlsx" 
      begin
        Roo::Excelx.new(file.path, {})
      rescue
        return false
      end
    else
      return false
    end
  end

  def update_data spreadsheet
    header = spreadsheet.row(1)
    billing = Billing.create(status: "processing")
    errors = ""
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      order = Order.find_by_shopify_id row["Order Id"]
      billings_orders = BillingsOrder.find_by_order_id order&.id
      if order.present? && billings_orders.nil? && order&.fulfillments.none?
        billings_order =  billing.billings_orders.new(order_id: order.id)
        fulfillment = order.fulfillments.new({"shopify_order_id"=>row["Order Id"], "fulfillment_id"=>nil, "status"=>"success", "service"=>"manual", "tracking_company"=>TRACKING_COMPANY, "tracking_number"=>row["Tracking No."], "tracking_url"=>TRACKING_URL + row["Tracking No."], "items"=>order.line_items.collect {|order| {name: order.name, quantity: order.quantity}} })
        if fulfillment.save
          billings_order.save
          order.line_items.each do |line_item| 
            line_item.update(fulfillable_quantity: 0)
            ProductService.new.update_fulfillable_quantity_each_item line_item.sku, line_item.quantity
            SupplyService.new.update_fulfillable_quantity_each_item line_item.sku, line_item.quantity, order.shop_id
          end
          order.update(fulfillment_status: "fulfilled")
        end
      else
        unless order.present? 
          errors += "#{row["Order Id"]} not present, "
        else
          unless order&.fulfillments&.none?
            errors += "#{row["Order Id"]} already created fulfillments, "
          end
        end
        unless billings_orders.nil?
          errors += "#{row["Order Id"]} already uploaded, "
        end
      end
    end
    if billing.billings_orders.none?
      billing.destroy
    end
    return [billing, errors]
  end
end