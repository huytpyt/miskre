class CusLineItemQuery < BaseQuery
  def self.single(cus_line_item)
    {
      id: cus_line_item.id,
      customer_id: cus_line_item.customer_id,
      sku: cus_line_item.sku,
      quantity: cus_line_item.quantity,
      shopify_line_item_id: cus_line_item.shopify_line_item_id,
      price: cus_line_item.price,
      title: cus_line_item.title,
      name: cus_line_item.name,
      on_system: cus_line_item.on_system,
      shop_id: cus_line_item.shop_id,
      created_at: cus_line_item.created_at,
      updated_at: cus_line_item.updated_at,
      product_image: images_for(cus_line_item.sku)
    }
  end

  def self.images_for(sku)
    product = Product.where(sku: sku).first
    image = product&.images&.first
    if image
      {
        id: image.id,
        original: image.file.url,
        thumb: image.file.url(:thumb),
        medium: image.file.url(:medium)
      }
    end
  end
end