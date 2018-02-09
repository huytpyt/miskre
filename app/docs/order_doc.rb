module OrderDoc
  extend Apipie::DSL::Concern

  api :GET, '/orders', "Get Orders List"
  param :id, :number, required: true
  param :page, :number
  param :limit, :number
  error :code => 401, :desc => "Unauthorized"
  error :code => 404, :desc => "Not Found"
  example <<-EOS
    {
    "paginator": {
        "total_records": 5,
        "records_per_page": 20,
        "total_pages": 1,
        "current_page": 1,
        "next_page": null,
        "prev_page": null,
        "first_page": 1,
        "last_page": 1,
        "option": "unavailable_fulfill_orders"
    },
    "orders": [
        {
            "id": 5234,
            "first_name": "rr",
            "last_name": "rr",
            "ship_address1": "gdgfd",
            "ship_address2": "34dfggd",
            "ship_city": null,
            "ship_state": null,
            "ship_zip": null,
            "ship_country": "Uzbekistan",
            "ship_phone": "534543",
            "email": "rrrr@gmail.com",
            "quantity": 1,
            "skus": "AGE * 1",
            "unit_price": "1600",
            "date": "2017-12-02T04:36:30.000Z",
            "remark": "",
            "shipping_method": "BEPG",
            "tracking_no": null,
            "fulfill_fee": null,
            "product_name": "book",
            "color": null,
            "size": null,
            "shop_id": 43,
            "created_at": "2017-12-02T04:36:46.865Z",
            "updated_at": "2017-12-02T04:37:00.931Z",
            "shopify_id": "175374008363",
            "financial_status": "paid",
            "fulfillment_status": null,
            "paid_for_miskre": null,
            "shop_name": "vokythoai",
            "total_cost": 1568.2
        },
        ....
    ]
}
  EOS
  def index; end
end
