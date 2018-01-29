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

  def tracking_number_option
    [['None', 'none'], ["Nil", 'nil']]
  end

  def billing_options
    [['Pending', 'pending'], ['Paid', 'paid'], ['Refunded', 'refunded']]
  end

  def body_data
    data = { view: "#{controller_path}##{action_name}" }
    data[:debug] = 'true' if Rails.env.development?
    data
  end

  def body_css_class
    controller_name = controller_path.underscore.tr('/', '-')
    "#{controller_name} #{controller_name}-#{css_action_name}"
  end

  def css_action_name
    action = action_name
    case action
    when 'update'
      'edit'
    when 'create'
      'new'
    else
      action
    end.tr('_', '-')
  end
end
