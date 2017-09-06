module ApplicationHelper
  def available_shops
    @shops = current_user.shops.select(:id, :name).all
    @shops.collect {|s| [s.name, s.id]}
  end

  def financial_options
    [['Pending', 'pending'], ['Authorized', 'authorized'],
     ['Partially Paid', 'partially_paid'], ['Paid', 'paid'],
     ['Partially Refunded', 'partially_refunded'],
     ['Refunded', 'refunded'], ['Voided', 'voided']]
  end

  def fulfillment_options
    [['Unfulfilled', 'null'], ['Fulfilled', 'fulfilled'],
     ['Partially fulfilled', 'partial']]
  end
end
