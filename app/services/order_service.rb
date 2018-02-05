class OrderService
  def sum_money_from_order order, base_cost
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
          supply_cost = base_cost ? product.cost : product.cus_cost
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
      total_money += sum_money_from_order(order, false)
    end
    return total_money
  end

  def accept_charge_orders request_charge_id
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
      request_charge.orders.update(request_charge_id: nil)
      request_charge.rejected!
      return { result: "Success", errors: nil }
    end
  end

  def create_fulfillment_for_order order_id, tracking_number
    order = Order.find order_id
    if order.present?
      ShopifyCommunicator.new(order.shop.id)
      items_name_array = []
      items_id_array = []
      order.line_items.each do |line_item|
        items_name_array.push({name: line_item.name, quantity: line_item.fulfillable_quantity})
        items_id_array.push({id: line_item.line_item_id, quantity: line_item.fulfillable_quantity})
      end
      get_courier = AfterShip::V4::Courier.detect({ tracking_number: tracking_number })
      courier = get_courier.try(:[], "data").try(:[], "couriers").first.try(:[], "name") || "MISKRE"
      courier_url = get_courier.try(:[], "data").try(:[], "couriers").first.try(:[], "web_url") || "http://www.17track.net/en/track?nums=#{tracking_number}"

      fulfillment = ShopifyAPI::Fulfillment.new(
        order_id: order.shopify_id,
        tracking_number: tracking_number,
        tracking_company: courier,
        tracking_url: courier_url,
        line_items: items_id_array)

      if fulfillment.save
        order.fulfillments.create(
          fulfillment_id: fulfillment.id,
          status: "fulfilled",
          service: fulfillment.service,
          tracking_company: fulfillment.tracking_company,
          shipment_status: fulfillment.shipment_status,
          tracking_number: fulfillment.tracking_number,
          tracking_url: fulfillment.tracking_url,
          shopify_order_id: order.shopify_id,
          items: items_name_array)

        order.update(fulfillment_status: "fulfilled")

        fulfillment_service.update_line_items order

        calculate_inventory_quantity(order)

        return { result: "Success", error: nil}
      else
        return { result: "Failed", error: "Fulfilled"}
      end
    end
    return { result: "Failed", error: "Can not find order with id #{order_id}"}
  end

  def calculate_inventory_quantity order
    product_info_sql = "SELECT products.sku, SUM(line_items.quantity) AS total_quantity
      FROM
      (((shops JOIN orders ON shops.id = orders.shop_id)
      JOIN line_items ON orders.id = line_items.order_id)
      JOIN products ON products.id = line_items.product_id)
      WHERE orders.id = #{order.id}
      GROUP BY products.sku
      ORDER BY total_quantity desc"

    product_info_result = Order.find_by_sql(product_info_sql)

    product_info_result.each do |product|
      inventories = Product.find_by_sku(product.sku).inventories
      quantity_must_fulfill = product.total_quantity

      inventories.in_stock.each do |inventory|
        if !quantity_must_fulfill.zero?
          if quantity_must_fulfill > inventory.quantity
            quantity_must_fulfill -= inventory.quantity
            inventory.quantity = 0
          else
            inventory.quantity -= quantity_must_fulfill
            quantity_must_fulfill = 0
          end
        end
        inventory.save
      end
    end
  end

  def order_statistics duration
    raw_sql = "SELECT products.sku, SUM(line_items.quantity) AS total_quantity
      FROM
      (((shops JOIN orders ON shops.id = orders.shop_id)
        JOIN line_items ON orders.id = line_items.order_id)
        JOIN products ON products.id = line_items.product_id)
      WHERE orders.created_at > '#{duration.days.ago.end_of_day}'
      GROUP BY products.sku
      ORDER BY total_quantity desc
      LIMIT 20"

    top_20_product = Shop.find_by_sql(raw_sql)

    ["Success", nil, top_20_product, duration]
  end

  def shop_statistics shop_id, current_user, duration
    duration ||= 7
    if current_user.user? && !current_user.shops.pluck(:id).include?(shop_id)
      return ["Failed", "This shop does not belong to you.", nil]
    end
    shop = Shop.where(id: shop_id).first
    if shop
      raw_sql ="SELECT products.sku, SUM(line_items.quantity) AS total_quantity
        FROM
        (((shops JOIN orders ON shops.id = orders.shop_id)
        JOIN line_items ON orders.id = line_items.order_id)
        JOIN products ON products.id = line_items.product_id)
        WHERE
        shops.id = #{shop_id}
        AND orders.created_at > '#{duration.days.ago.end_of_day}'
        GROUP BY products.sku
        ORDER BY total_quantity desc"

      shop_statistics_data = Shop.find_by_sql(raw_sql)

      shop_orders = Order.where("created_at > :duration", duration: duration.days.ago.end_of_day)

    product_quantity_sql = "SELECT products.sku, SUM(line_items.quantity) AS total_quantity
      FROM
      (((shops JOIN orders ON shops.id = orders.shop_id)
      JOIN line_items ON orders.id = line_items.order_id)
      JOIN products ON products.id = line_items.product_id)
      WHERE orders.created_at > '#{duration.days.ago.end_of_day}'
      AND shops.id = #{shop_id}
      GROUP BY products.sku
      ORDER BY total_quantity desc"

    product_quantity_sql_result = Shop.find_by_sql(product_quantity_sql)

    total_profit = product_quantity_sql_result.inject(0) do |profit, row|
                    product = Product.find_by_sku row.sku
                    profit += (((product.suggest_price + product.epub) - (product.cus_cost + product.cus_epub)).round(2)*row.total_quantity).round(2)
                  end.round(2)

    product_by_orders_sql = "SELECT products.sku, orders.id AS order_id, shops.id AS shop_id, line_items.quantity
        FROM
        (((shops JOIN orders ON shops.id = orders.shop_id)
        JOIN line_items ON orders.id = line_items.order_id)
        JOIN products ON products.id = line_items.product_id)
        WHERE orders.created_at > '#{duration.days.ago.end_of_day}'
        AND shops.id = #{shop_id}"

    product_by_orders = Product.find_by_sql(product_by_orders_sql)

    total_revenue = product_by_orders.inject(0) do |revenue, row|
                    shop = Shop.find row["shop_id"]
                    product = Product.find_by_sku row["sku"]
                    order = Order.find row["order_id"]

                    country = ISO3166::Country.find_by_name(order.ship_country)
                    ship_country =  country.present? ? country[0] : "US"
                    nation = Nation.find_by_code ship_country
                    shipping_method = order.shipping_method.upcase
                    shipping_type = (nation&.shipping_types&.find_by_code shipping_method) || ShippingType.first
                    shipping_cost = CarrierService.cal_cost(shipping_type, product.weight) || 0

                    rate = product.cus_epub*shop.shipping_rate
                    shipping_price = shipping_cost - rate

                    revenue += (((product.suggest_price + shipping_price).round(2))*row["quantity"]).round(2)
                  end.round(2)

    else
      return ["Failed", "Can not find shop with id #{shop_id}", nil]
    end

    ["Success", nil, shop_statistics_data, total_revenue, total_profit, shop, duration]
  end

  def self.check_order_available order_list
    order_list_id = order_list.pluck(:id)
    product_info_sql = "SELECT products.sku, line_items.sku as variant_sku, line_items.quantity as variant_quantity, SUM(line_items.quantity) AS total_quantity, orders.id AS order_id
      FROM
      (((shops JOIN orders ON shops.id = orders.shop_id)
      JOIN line_items ON orders.id = line_items.order_id)
      JOIN products ON products.id = line_items.product_id)
      WHERE orders.id IN #{order_list_id.to_s.gsub("[", "(").gsub("]", ")")}
      GROUP BY products.sku, orders.id, variant_sku, variant_quantity
      ORDER BY total_quantity desc"

    product_info_result = Product.find_by_sql(product_info_sql)

    product_sku_array = product_info_result.pluck(:sku)

    inventory_by_product_sql = "SELECT inventories.id, inventory_variants.id as inventory_variant_id, products.sku, variants.sku as variant_sku, inventories.cost as inventory_cost, inventory_variants.cost as variant_cost, SUM(inventories.in_stock) as inventory_quantity, sum(inventory_variants.in_stock) as variant_quantity
      FROM (products JOIN inventories ON products.id = inventories.product_id
      LEFT JOIN (inventory_variants JOIN variants ON variants.id = inventory_variants.variant_id) ON inventory_variants.inventory_id = inventories.id)
      WHERE products.sku IN #{product_sku_array.to_s.gsub("[", "(").gsub("]", ")").tr('"', "'")}
      GROUP BY products.sku, variant_sku, inventories.cost, inventory_variants.cost, inventories.id, inventory_variants.id
      ORDER BY CASE WHEN variants.sku IS NOT NULL THEN
                inventory_variants.cost
                ELSE
                inventories.cost
                END DESC"

    inventory_by_product_result = Product.find_by_sql(inventory_by_product_sql)

    orders_available_id = []
    orders_unavailabe_id = []
    pickup_info = []

    product_info_result.group_by{|info| info["order_id"] }.each do |order_id, line_items|
      alert = []
      line_items.each do |item|
        is_have_variant = item["sku"] != item["variant_sku"]
        item_sku = is_have_variant ? item["variant_sku"] : item["sku"]

        product_in_inventory = is_have_variant ? inventory_by_product_result.select{|a| a.variant_sku == item.variant_sku} : inventory_by_product_result.select{|a| a.sku == item.sku}
        in_stock = is_have_variant ? product_in_inventory.inject(0){|sum, a| sum += a["variant_quantity"].to_i }
          : product_in_inventory.inject(0){|sum, a| sum += a["inventory_quantity"].to_i }

        order_quantity = is_have_variant ? item.variant_quantity : item.total_quantity
        @valid_order = true

        if product_in_inventory.present? && order_quantity <= in_stock.to_i
          product_in_inventory.each do |inventory|
            if is_have_variant
              if order_quantity >= inventory.variant_quantity
                order_quantity -= inventory.variant_quantity
                pickup_info << { inventory_id: inventory.try(:id), variant_id: inventory.try(:inventory_variant_id), quantity: inventory.variant_quantity, cost: inventory.variant_cost.to_f, order_id: order_id}
                inventory.variant_quantity = 0
              else
                inventory.variant_quantity -= order_quantity
                pickup_info << { inventory_id: inventory.try(:id), variant_id: inventory.try(:inventory_variant_id), quantity: order_quantity, cost: inventory.variant_cost.to_f, order_id: order_id}
                order_quantity = 0
              end
            else
              if order_quantity >= inventory.inventory_quantity
                order_quantity -= inventory.inventory_quantity
                pickup_info << { inventory_id: inventory.try(:id), variant_id: inventory.try(:inventory_variant_id), quantity: inventory.inventory_quantity, cost: inventory.inventory_cost.to_f, order_id: order_id}
                inventory.inventory_quantity = 0
              else
                inventory.inventory_quantity -= order_quantity
                pickup_info << { inventory_id: inventory.try(:id), variant_id: inventory.try(:inventory_variant_id), quantity: order_quantity, cost: inventory.inventory_cost.to_f, order_id: order_id}
                order_quantity = 0
              end
            end if order_quantity > 0
          end
        else
          @valid_order = false
          alert << "Request #{order_quantity} #{item_sku} but in stock is #{in_stock.to_i}"
        end
      end
      order = Order.find order_id
      order.stock_warning = alert.presence
      order.save

      @valid_order ? orders_available_id << order_id : orders_unavailabe_id << order_id
    end

    orders_available_id = orders_available_id.uniq - orders_unavailabe_id
    orders_available = Order.where(id: orders_available_id)
    orders_unavailable = Order.where(id: orders_unavailabe_id)
    [orders_available, orders_unavailable, pickup_info]
  end

  def self.download_orders order_list_id
    order_list_id = JSON.parse(order_list_id)
    orders = Order.where(id: order_list_id)
    orders_available, orders_unavailable, pickup_info = OrderService.check_order_available(orders)

    ActiveRecord::Base.transaction do
      @excel = Axlsx::Package.new do |p|
                p.workbook.add_worksheet(name: "Orders") do |sheet|
                  sheet.add_row ["Order ID", "Products"]
                  pickup_info.group_by{|data| data[:order_id] }.each do |order|
                    order_detail = Order.find order[0]
                    order_detail.pickup_info = order[1]
                    order_detail.save

                    info = product_info(order[1])
                    sheet.add_row [order[0], info], height: 50
                  end
                end
              end
      pickup_info.each do |line|
        object = InventoryVariant.where(id: line[:variant_id]).first || Inventory.where(id: line[:inventory_id]).first
        object.in_stock -= line[:quantity].to_i
        object.save
      end
    end
    out_file = File.new(File.join(Dir.pwd, "/excel_file/Orders_#{Time.zone.now}.xlsx"), "w")
    out_file.write(@excel.to_stream.read)
    out_file.close
    out_file.path
  end

  def self.product_info data
    info = ""
    data.each do |order|
      object =  InventoryVariant.where(id: order[:variant_id]).first || Inventory.where(id: order[:inventory_id]).first
      product_name = object.inventory.product.name || object.product.name
      option1 = object.try(:variant).try(:option1)
      option2 = object.try(:variant).try(:option2)
      option3 = object.try(:variant).try(:option3)
      product_sku = object.inventory.product.sku || object.product.sku
      variant_sku = object.try(:variant).try(:sku)
      quantity = order[:quantity]
      cost = order[:cost]
      info << "Product Name: #{product_name} - #{option1} #{option2} #{option3} SKU: #{product_sku} (#{variant_sku}), Quantity: #{quantity}, Cost: #{cost}" + "\n"
    end

    return info
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