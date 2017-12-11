class InvoicesQuery < BaseQuery
  def self.list(invoices, per_page = LIMIT_RECORDS)
    {
      invoices: invoices
    }
  end
end