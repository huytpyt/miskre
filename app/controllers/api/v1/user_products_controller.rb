class Api::V1::UserProductsController < Api::V1::BaseController
  def matching_products
    render json: UserProductQuery.matching_products(params)
  end

  def sync_product_to_shopify
    render json: UserProductQuery.sync_product_to_shopify(params)
  end
end
