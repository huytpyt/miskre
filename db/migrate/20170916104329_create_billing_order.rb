class CreateBillingOrder < ActiveRecord::Migration[5.0]
  def change
    create_table :billings_orders do |t|
      t.belongs_to :billing, index: true
      t.string :order_shopify_id
      t.timestamps
    end
  end
end
