class OrderService
  def sum_money_from_order order
    shop = order.shop
    skus_array = order.skus.split(",").map {|a| a.split("*")[0].strip}
    quantities = order.skus.split(",").map {|a| a.split("*")[1].strip}
    shipping_method = order.shipping_method.upcase
    country = ISO3166::Country.find_by_name(order.ship_country)
    ship_country =  country.present? ? country[0] : "US"
    nation = Nation.find_by_code ship_country
    shipping_type = (nation&.shipping_types&.find_by_code shipping_method) || ShippingType.first
    index = 0
    sum = 0
    if shipping_type.present?
      skus_array.each do |sku|
        product = Product.find_by_sku(sku.first(3))
        if product.present?
          user = shop.user
          shipping_cost = CarrierService.cal_cost(shipping_type, product.weight)
          supply_cost = product.cus_cost
          sum += (quantities[index].to_i * (supply_cost.to_f + shipping_cost.to_f))
          index += 1
        end
      end
    end
    return sum.round(2)
  end

  def sum_money_per_bill bill_id
    bill = Billing.find bill_id
    total_money = 0
    bill.orders.each do |order|
      total_money += sum_money_from_order(order)
    end
    return total_money
  end

  def accept_charge_orders request_charge_id, tracking_number_array
    reponse_result = []
    request_charge = RequestCharge.find request_charge_id
    ActiveRecord::Base.transaction do
      @error = []
      user = request_charge.user
      order_list_id = request_charge.orders.pluck(:id)
      order_list = Order.where(id: order_list_id)

      user_balance = user.balance
      user_balance.lock!
      if user_balance.nil?
        @error << "This user does not have any balance."
        raise ActiveRecord::Rollback
      end

      amount_must_paid = request_charge.total_amount
      if request_charge.pending? && !orders_paid?(order_list)
        if amount_must_paid <= user_balance.total_amount
          new_user_balance = user.balance.total_amount - amount_must_paid
          user_balance.total_amount = new_user_balance
          user_balance.save!
          request_charge.approved!
          order_list.update_all(paid_for_miskre: true)
          generate_invoice_for_orders(user, -amount_must_paid, order_list, "", new_user_balance)
          eval(tracking_number_array).each do |tracking_info|
            result, error = create_fulfillment_for_order(tracking_info[:order_id].to_i, tracking_info[:tracking_number].to_s)
            raise ActiveRecord::Rollback if error.present?
          end
        else
          @error << "This account does not have enough balance"
        end
      else
        @error << "Some of orders had paid or rejected"
      end
    end
    if @error.blank?
      ["OK", request_charge.total_amount, nil]
    else
      ["Failed", 0, @error]
    end
  rescue Exception => error
    ["Failed", 0, error]
  end

  def reject_charge_orders request_charge_id
    request_charge = RequestCharge.find request_charge_id
    if request_charge.approved?
      return { result: "Failed", errors: "This order is approved." }
    else
      request_charge.rejected!
      return { result: "Success", errors: nil }
    end
  end

  def create_fulfillment_for_order order_id, tracking_number
    order = Order.find order_id
    if order.present?
      ShopifyCommunicator.new(order.shop.id)
      line_item_id_array = []
      items_name_array = []
      line_item_sku_array = []
      line_item_quantity_array = []

      order.line_items.each do |line_item|
        line_item_id_array << line_item.line_item_id
        items_name_array << line_item.name
        line_item_sku_array << line_item.sku
        line_item_quantity_array << line_item.quantity
      end

      array_size = order.line_items.size
      line_item_array = []
      items_array = []
      items_array_sku = []

      array_size.times do |index|
        line_item_array.push({id: line_item_id_array[index].to_i, quantity: line_item_quantity_array[index].to_i})
        items_array.push({name: items_name_array[index], quantity: line_item_quantity_array[index].to_i})
        items_array_sku.push({sku: line_item_sku_array[index], quantity: line_item_quantity_array[index].to_i})
      end

      get_courier = AfterShip::V4::Courier.detect({ tracking_number: tracking_number })
      courier = get_courier.try(:[], "data").try(:[], "couriers").first.try(:[], "name")
      courier_url = get_courier.try(:[], "data").try(:[], "couriers").first.try(:[], "web_url")

      fulfillment = ShopifyAPI::Fulfillment.new(
        order_id: order.shopify_id,
        tracking_number: tracking_number,
        tracking_company: courier,
        tracking_url: courier_url,
        line_items: line_item_array)

      if fulfillment.save
        order.fulfillments.create(
          fulfillment_id: fulfillment.id,
          status: fulfillment.status,
          service: fulfillment.service,
          tracking_company: fulfillment.tracking_company,
          shipment_status: fulfillment.shipment_status,
          tracking_number: fulfillment.tracking_number,
          tracking_url: fulfillment.tracking_url,
          items: items_array)

        order.update(fulfillment_status: ShopifyAPI::Order.find(:first, params: {id: order.shopify_id}).fulfillment_status)

        return { result: "Sucess", error: nil}
      else
        # fulfillment_service.update_line_items order
        return { result: "Failed", error: fulfillment.status}
      end
    end
    return { result: "Failed", error: "Can not find order with id #{order_id}"}
  end

  private
    def generate_invoice_for_orders user, amount, orders, memo, balance
      invoice = Invoice.create(
        user_id: user.id,
        money_amount: amount,
        memo: memo,
        balance: balance
      )
      invoice.orders << orders
      invoice.order_pay!
    end

    def orders_paid? order_list
      order_list.pluck(:paid_for_miskre).include?(true)
    end

    def fulfillment_service
      @fulfillment_service ||= FulfillmentService.new
    end
end