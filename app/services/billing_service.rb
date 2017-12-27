class BillingService
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv"
      begin
        Roo::CSV.new(file.path, {})
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
    billing = Billing.create()
    errors = ""
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      order = Order.find_by_shopify_id row["Order No."].to_i
      billings_orders = BillingsOrder.find_by_order_id order&.id
      if order.present? && billings_orders.nil? && order&.fulfillments.none?
        billings_order =  billing.billings_orders.new(order_id: order.id)
        fulfillment = order.fulfillments.new({"shopify_order_id"=>row["Order No."].to_i.to_s, "fulfillment_id"=>nil, "status"=>"success", "service"=>"manual", "tracking_company"=>TRACKING_COMPANY, "tracking_number"=>row["Tracking No."].to_s, "tracking_url"=>TRACKING_URL + row["Tracking No."].to_s, "items"=>order.line_items.collect {|order| {name: order.name, quantity: order.quantity}} })
        if fulfillment.save
          billings_order.save
          FulfillmentService.new.update_line_items order
          order.update(fulfillment_status: "fulfilling")
        end
      else
        unless order.present? 
          errors += "#{row["Order No."]} not present, "
        else
          unless order&.fulfillments&.none?
            errors += "#{row["Order No."]} already created fulfillments, "
          end
        end
        unless billings_orders.nil?
          errors += "#{row["Order No."]} already uploaded, "
        end
      end
    end
    if billing.billings_orders.none?
      billing.destroy
    end
    return [billing, errors]
  end
end