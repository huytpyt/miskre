ShopifyApp.configure do |config|
  config.api_key = "db4490d18b89d1a5b54af8f9fff9df9b"
  config.secret = "856da6a99df9e70eeb23a7cf8029eb97"
  config.scope = "read_orders, read_products, write_products"
  # TODO
  # read_products,write_products,read_customers,write_customers,read_orders,write_orders,read_fulfillments,write_fulfillments
  # config.embedded_app = true
  config.embedded_app = false
end
