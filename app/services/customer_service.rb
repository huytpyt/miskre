class CustomerService
  class << self
    def sync_customers
      Shop.all.each do |shop|
        begin
          communicator = ShopifyCommunicator.new(shop.id)
          communicator.sync_customers
        rescue
          p 'This shop already removed'
        end
      end
    end

    def customers_statictis
      item_statistic_sql = 'SELECT cus_line_items.title,
        SUM(cus_line_items.quantity) AS total_quantity FROM cus_line_items
        JOIN customers ON customers.id = cus_line_items.customer_id
        GROUP BY cus_line_items.title ORDER BY total_quantity DESC'

      item_statistic_result = CusLineItem.find_by_sql(item_statistic_sql)
      item_statistic_result.inject([]) do |json, item|
        data = {
          title: item['title'],
          total_quantity: item['total_quantity'],
          customer_statistic: get_customers_by_product(item)
        }
        json << data
      end
    end

    def get_customers_by_product item
      customers_statistic_sql = "SELECT customers.email,
        SUM(cus_line_items.quantity) as quantity
        FROM customers JOIN cus_line_items
        ON customers.id = cus_line_items.customer_id
        WHERE cus_line_items.title = $$#{item['title']}$$
        GROUP BY customers.email
        ORDER BY quantity DESC"

      customers_statistic_result = Customer.find_by_sql(customers_statistic_sql)
      customers_statistic_result.inject([]) do |json, customer|
        data = {
          customer_id: Customer.find_by_email(customer['email']).id,
          email: customer['email'],
          quantity: customer['quantity']
        }
        json << data
      end
    end
  end
end