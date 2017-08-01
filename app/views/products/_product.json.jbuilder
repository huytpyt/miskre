json.extract! product, :id, :name, :weight, :length, :height, :width, :sku, :desc, :price, :compare_at_price, :created_at, :updated_at
json.url product_url(product, format: :json)
