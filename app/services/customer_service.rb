class CustomerService
  class << self
    def sync_customers
      Shop.all.each do |shop|
        begin
          communicator = ShopifyCommunicator.new(shop.id)
          communicator.sync_customers
        rescue
          p "This shop already removed"
        end
      end
    end
  end
end