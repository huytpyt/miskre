# == Schema Information
#
# Table name: detail_invoices
#
#  id         :integer          not null, primary key
#  invoice_id :integer
#  order_id   :integer
#  amount     :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DetailInvoice < ApplicationRecord
  belongs_to :invoice
  belongs_to :order

end
