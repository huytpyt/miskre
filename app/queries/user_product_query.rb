class UserProductQuery < BaseQuery

  def self.list(page = 1, per_page = 12, sort, order_by, search)
    user_products = UserProduct.all
    sort_options =  { "#{order_by}" => sort }
    paginate = api_paginate(user_products.includes(:images).order(sort_options).search(search), page).per(per_page)
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
      user_products: paginate.map{ |user_product| single(user_product) }
    }
  end

  def self.single user_product
    {
      id: user_product.id,
      name: user_product.name,
      weight: user_product.weight,
      length: user_product.length,
      height: user_product.height,
      width: user_product.width,
      sku: user_product.sku,
      desc: user_product.desc,
      price: user_product.price,
      compare_at_price: user_product.compare_at_price,
      quantity: user_product.quantity,
      shopify_product_id: user_product.shopify_product_id,
      user_id: user_product.user_id,
      shop_id: user_product.shop_id,
      is_request: user_product.is_request,
      status: user_product.status,
      cost: user_product.cost,
      suggest_price: user_product.suggest_price,
      images: images_for(user_product)
    }
  end

  def self.images_for(user_product)
    user_product.images.map do |image|
      {
        id: image.id,
        original: image.file.url,
          thumb: image.file.url(:thumb),
          medium: image.file.url(:medium),
          created_at: image.created_at,
        updated_at: image.updated_at
      }
    end
  end


end