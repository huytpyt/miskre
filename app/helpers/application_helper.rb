module ApplicationHelper
  def available_shops
    @shops = Shop.select(:id, :name).all
    @shops.collect {|s| [s.name, s.id]}
  end
end
