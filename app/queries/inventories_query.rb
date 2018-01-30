class InventoriesQuery < BaseQuery

  def self.single inventory
    {
      id: inventory.id,
      product_id: inventory.product_id,
      quantity: inventory.quantity,
      cost: inventory.cost,
      in_stock: inventory.in_stock,
      product: ProductsQuery.single(inventory.product),
      inventory_variants: inventory.inventory_variants.map{ |variant| InventoryVariantQuery.single(variant)}
    }
  end

  def self.list(page = 1, per_page = 12, sort, order_by, search, current_resource)
    sort_options = { "#{order_by}" => sort }
    inventories = Inventory.all
    paginate = api_paginate(inventories.order(sort_options).search(search), page).per(per_page)
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
      inventories: paginate.map{ |inventory| single(inventory) }
    }
  end

end