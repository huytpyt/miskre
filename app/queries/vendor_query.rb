class VendorQuery < BaseQuery

  extend BuildQuery

  def self.has_association
    ["inventories"]
  end

  def self.list(page = 1, per_page = 12, sort, order_by, search)
    build_list_query(Vendor, page, per_page, sort, order_by, search, has_association)
  end

  def self.single(vendor)
    build_single_query(Vendor, vendor, has_association)
  end

end