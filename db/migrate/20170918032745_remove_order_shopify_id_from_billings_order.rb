class RemoveOrderShopifyIdFromBillingsOrder < ActiveRecord::Migration[5.0]
  def change
    remove_column :billings_orders, :order_shopify_id
    add_reference :billings_orders, :order, index: true
  end
end
