json.extract! request_product, :id, :product_name, :link, :status, :created_at, :updated_at
json.url request_product_url(request_product, format: :json)
