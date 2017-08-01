module ApplicationHelper
  def available_shops
    @shops = Shop.select(:id, :shopify_domain).all
    @shops.collect {|s| [s.shopify_domain, s.id]}
  end
end
