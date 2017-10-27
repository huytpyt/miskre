class UserService
  def self.update_paid_status current_user
    customer = Stripe::Customer.retrieve(current_user.customer_id)
    invoice = customer.invoices&.first
    if invoice.present?
      User.update(is_paid: invoice&.paid, period_end: Time.at(invoice&.lines&.first&.period&.end))
    end
  end
end