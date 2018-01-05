namespace :line_items do
  desc "Update line_items product id"
  task update_product_id: :environment do
    LineItem.all.each {|line_item| line_item.update(product_id: Product.find_by_sku(line_item.sku.first(3)).id)}
    p "========DONE=========="
  end

end
