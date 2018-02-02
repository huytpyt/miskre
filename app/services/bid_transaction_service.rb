class BidTransactionService
  extend CrudForApi

  class << self
    def toggle_status bid_transaction_id
      data = model_read(BidTransaction, bid_transaction_id)
      bid_transaction = data[:bid_transaction]
      if bid_transaction
        if bid_transaction.pending?
          bid_transaction.reject!
        elsif bid_transaction.reject?
          bid_transaction.pending!
        end
      end
      return model_read(BidTransaction, bid_transaction_id)
    end
  end

end