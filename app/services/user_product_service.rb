class UserProductService
  def self.matching_products user_product_id, miskre_product_id
    ActiveRecord::Base.transaction do
      @user_product = UserProduct.find user_product_id
      miskre_product = Product.find miskre_product_id

      @user_product.sku = miskre_product.sku
      @user_product.cost = miskre_product.cost
      @user_product.weight = miskre_product.weight
      @user_product.length = miskre_product.length
      @user_product.height = miskre_product.height
      @user_product.width = miskre_product.width
      @user_product.approve!
    end
    return { status: "Success", errors: nil } if @user_product.save
  rescue Exception => e
    return { status: "Failed", errors: e.message }
  end

  def self.sync_product_to_shopify params
    shop = Shop.first params[:shop_id]
    session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    product_need_sync = UserProduct.find params[:product_id]
    shopify_product = ShopifyAPI::Product.find(product_need_sync.shopify_product_id)
    shopify_product_variant = ShopifyAPI::Variant.find shopify_product.variants.first.id
  end
end