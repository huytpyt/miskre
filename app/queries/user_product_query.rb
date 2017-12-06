class UserProductQuery < BaseQuery

  def self.matching_products params
    user_product_id = params[:user_product_id]
    miskre_product_id = params[:miskre_product_id]
    response = UserProductService.matching_products(user_product_id, miskre_product_id)
  end

  def self.sync_product_to_shopify params
    response = UserProductService.sync_product_to_shopify(params)
  end
end