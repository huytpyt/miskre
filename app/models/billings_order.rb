class BillingsOrder < ApplicationRecord
  belongs_to :billing
  belongs_to :order
end