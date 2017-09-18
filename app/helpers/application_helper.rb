module ApplicationHelper
  def available_shops
    if current_user.staff?
      @shops = Shop.all.select(:id, :name).all
    else
      @shops = current_user.shops.select(:id, :name).all
    end
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

  def billing_options
    [['Pending', 'pending'], ['Paid', 'paid'], ['Refunded', 'refunded']]
  end
end
