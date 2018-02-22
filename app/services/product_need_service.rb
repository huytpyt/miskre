class ProductNeedService
  extend CrudForApi

  class << self

    def create product_need_params
      data = model_create(ProductNeed, product_need_params)
      product_need = data[:product_need]
      product_need.suspend!
      model_read(ProductNeed, product_need.id)
    end

    def update product_need_id, product_need_params
      model_update(ProductNeed, product_need_id, product_need_params)
    end

    def show product_need_id
      data = model_read(ProductNeed, product_need_id)
    end

    def change_status params
      product_need_id = params[:id]
      new_status = params[:status]
      data = model_read(ProductNeed, product_need_id)
      product_need = data[:product_need]
      product_need.status = new_status
      if product_need.save
        product_need.bid_transactions.where(status: "pending").update_all(status: "reject") if product_need.finish?
      end
      return model_read(ProductNeed, product_need_id)
    end
  end
end