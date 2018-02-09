class InventoryVariantQuery < BaseQuery
  extend BuildQuery

  class << self
    def single(inventory_variant)
      build_single_query(InventoryVariant, inventory_variant)
    end
  end
end
