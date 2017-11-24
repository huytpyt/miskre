class SuppliesQuery < BaseQuery

  def self.list(page = 1, per_page = 12, search = '', supplies, shop)
    if search.present?
      paginate = api_paginate(supplies.search(search).records, page).per(per_page)
    else
      paginate = api_paginate(supplies, page).per(per_page)
    end
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
      shop: shop,
      supplies: paginate.map{ |supply| {supply: get_supply_infor(supply), variants: supply.supply_variants, product: get_product_infor(supply.product)}}
    }
  end

  def self.get_product_infor product
    {weight: product.weight, sku: product.sku, product_url: product.product_url}
  end

  def self.get_supply_infor supply
    profit = ((supply.price + supply.epub) - (supply.cost + supply.cost_epub)).round(2)
    {id: supply.id, product_id: supply.product_id, shop_id: supply.shop_id, created_at: supply.created_at, updated_at: supply.updated_at, desc: supply.desc, price: supply.price, name: supply.name, original: supply.original, epub: supply.epub, cost_epub: supply.cost_epub, compare_at_price: supply.compare_at_price, cost: supply.cost, keep_custom: supply.keep_custom, is_deleted: supply.is_deleted, profit: profit}
  end

end