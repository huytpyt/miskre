class Fulfillment < ApplicationRecord
  belongs_to :order
  serialize :items
end
