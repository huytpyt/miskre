class ProductNeedQuery < BaseQuery

  extend BuildQuery

  def self.has_association
    ["bid_transactions"]
  end

  def self.list(page = 1, per_page = 12, sort, order_by, search)
    build_list_query(ProductNeed, page, per_page, sort, order_by, search, has_association)
  end

  def self.single(product_need)
    build_single_query(ProductNeed, product_need, has_association)
  end

end