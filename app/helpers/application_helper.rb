module ApplicationHelper
  def available_shops
    @shops = current_user.shops.select(:id, :name).all
    @shops.collect {|s| [s.name, s.id]}
  end
end
