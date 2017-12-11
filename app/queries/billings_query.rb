class BillingsQuery < BaseQuery
  def self.single billing
    {
      id: billing.id,
      address_city: billing.address_city,
      address_country: billing.address_country,
      address_line1: billing.address_line1,
      address_line2: billing.address_line2,
      address_state: billing.address_state,
      address_zip: billing.address_zip,
      brand: billing.brand,
      country: billing.country,
      exp_month: billing.exp_month,
      exp_year: billing.exp_year,
      funding: billing.funding,
      last4: billing.last4,
      name: billing.name
    }
  end
end