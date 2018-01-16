class UserProductService

  class << self
    def matching_products user_product_id, miskre_product_id
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
      UserProductService.sync_product_to_shopify(@user_product.shop_id, user_product_id, miskre_product_id)
      return { status: "Success", errors: nil } if @user_product.save
    rescue Exception => e
      return { status: "Failed", errors: e.message }
    end

    def sync_product_to_shopify shop_id, user_product_id, miskre_product_id
      shop = Shop.find shop_id
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      product_need_sync = UserProduct.find user_product_id
      shopify_product = ShopifyAPI::Product.find(product_need_sync.shopify_product_id)
      shopify_product_variant = ShopifyAPI::Variant.find shopify_product.variants.first.id
    end

    def accept_with_matched_product user_product_id, matched_product_id
      user_product = UserProduct.find user_product_id
      matched_product_id = Product.find matched_product_id
      ActiveRecord::Base.transaction do
        new_supply = Supply.new(
          product_id: matched_product_id.id,
          shop_id: user_product.shop_id,
          shopify_product_id: user_product.shopify_product_id,
          name: user_product.name,
          desc: user_product.desc,
          price: user_product.price,
          compare_at_price: user_product.suggest_price,
          is_deleted: true
        )

        if new_supply.valid?
          new_supply.save
          user_product.images.each do |image|
            new_image = image.dup
            new_image.imageable_type = "Supply"
            new_image.imageable_id = new_supply.id
            new_image.save
          end

          user_product.user_variants.includes(:images).each do |variant|
            supply_variant = SupplyVariant.create(
              option1: variant.option1,
              option2: variant.option2,
              option3: variant.option3,
              price: variant.price,
              sku: variant.sku,
              supply_id: new_supply.id,
              compare_at_price: variant.compare_at_price
              )
            variant.images.each do |image|
              new_image = image.dup
              new_image.imageable_type = "SupplyVariant"
              new_image.imageable_id = supply_variant.id
              new_image.save
            end
          end

          return ["Success", nil, new_supply]
        else
          return ["Failed", new_supply.errors.messages, nil]
        end
      end
    end

    def accept_as_new_product user_product_id
      user_product = UserProduct.find user_product_id
      shop = Shop.find user_product.shop_id
      ActiveRecord::Base.transaction do
        new_product = Product.new(
          name: user_product.name,
          weight: user_product.weight.to_f,
          length: user_product.length.to_f,
          height: user_product.height.to_f,
          width: user_product.width.to_f,
          sku: user_product.sku,
          desc: user_product.desc,
          price: user_product.price,
          compare_at_price: user_product.compare_at_price,
          shop_id: user_product.shop_id,
          suggest_price: user_product.suggest_price,
          cost: user_product.price
        )
        if new_product.valid?
          new_product.save
          user_product.images.each do |image|
            new_image = image.dup
            new_image.imageable_type = "Product"
            new_image.imageable_id = new_product.id
            new_image.save
          end

          user_product.user_variants.includes(:images).each do |variant|
            new_variant = Variant.create(
              option1: variant.option1,
              option2: variant.option2,
              option3: variant.option3,
              price: variant.price,
              sku: variant.sku,
                compare_at_price: variant.compare_at_price,
              product_id: new_product.id
            )
            variant.images.each do |image|
              new_image = image.dup
              new_image.imageable_type = "Variant"
              new_image.imageable_id = new_variant.id
              new_image.save
            end
          end

          new_supply = Supply.create(
            product_id: new_product.id,
            shop_id: user_product.shop_id,
            shopify_product_id: user_product.shopify_product_id,
            desc: user_product.desc,
            price: user_product.price,
            name: user_product.name,
            user_id: shop.user_id,
            compare_at_price: user_product.compare_at_price,
            cost: user_product.cost,
            is_deleted: true
          )

          return ["Success", nil, new_product]
        else
          return ["Failed", new_product.errors.messages, nil]
        end
      end
    end

  end
end