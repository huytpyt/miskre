require 'sidekiq-scheduler'

class SyncCustomers
  include Sidekiq::Worker

  def perform
    CustomerService.sync_customers()
  end

end
