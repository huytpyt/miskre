class UserQuery < BaseQuery

  def self.add_balance params, user
    response_result, amount, user, errors, current_balance = UserService.add_new_balance(params, user)
    {
      status: response_result,
      amount: amount,
      user_id: user.id,
      email: user.email,
      errors: errors,
      current_balance: current_balance
    }
  end

  def self.add_balance_manual params
    response_result, amount, user, errors, current_balance = UserService.add_balance_manual(params)
    {
      status: response_result,
      amount: amount,
      user_id: user&.id,
      email: user&.email,
      errors: errors,
      current_balance: current_balance
    }
  end

  def self.refund_balance params
    response_result, amount, user, errors, current_balance = UserService.refund_balance(params)
    {
      status: response_result,
      amount: amount,
      user_id: user&.id,
      email: user&.email,
      errors: errors,
      current_balance: current_balance
    }
  end

  def self.list(page = 1, per_page = 12, sort, order_by, search)
    users = User.all
    sort_options = { "#{order_by}" => sort }
    if users.blank?
      {
        users: []
      }
    else
      paginate = api_paginate(users.order(sort_options).search(search), page).per(per_page)
      {
        paginator: {
          total_records: paginate.total_count,
          records_per_page: paginate.limit_value,
          total_pages: paginate.total_pages,
          current_page: paginate.current_page,
          next_page: paginate.next_page,
          prev_page: paginate.prev_page,
          first_page: 1,
          last_page: paginate.total_pages
        },
        users: paginate.map{ |user| single(user) }
      }
    end
  end

  def self.single user
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      customer_id: user.customer_id,
      is_paid: user.is_paid,
      period_end: user.period_end,
      parent_id: user.parent_id,
      reference_code: user.reference_code,
      enable_ref: user.enable_ref,
      fb_link: user.fb_link,
      shops: user.shops.map{ |shop| shop_info(shop)}
    }
  end

  def self.shop_info shop
    {
      shop_name: shop.name,
      shop_id: shop.id
    }
  end

  def self.user_relations user
    {
      current_user: _user(user),
      parent: _user(user.parent_user),
      childs: user.child_users.map{ |user| _user(user) }
    }
  end

  def self._user user
    {
      id: user.id,
      email: user.email,
      name: user.name
    }
  end

  def self.request_charge_orders order_list_id, user
    UserService.request_charge_orders(order_list_id, user)
  end
end