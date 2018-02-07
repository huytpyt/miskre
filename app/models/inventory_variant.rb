# == Schema Information
#
# Table name: inventory_variants
#
#  id           :integer          not null, primary key
#  inventory_id :integer
#  quantity     :integer
#  variant_id   :integer
#  cost         :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  in_stock     :integer
#

class InventoryVariant < ApplicationRecord
  belongs_to :variant
  belongs_to :inventory

  scope :asc, -> { order("created_at ASC") }

  after_commit do
    inventory.quantity = inventory.inventory_variants.inject(0){ |total_quantity, variant| total_quantity += variant.quantity}
    inventory.save
  end
end
