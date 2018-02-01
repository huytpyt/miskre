class ProductNeedService
  extend CrudForApi

  class << self

    def create product_need_params
      model_create(ProductNeed, product_need_params)
    end

    def update product_need_id, product_need_params
      model_update(ProductNeed, product_need_id, product_need_params)
    end

    def show product_need_id
      data = model_read(ProductNeed, product_need_id)
      product_need = data[:product_need]
      if product_need
        product_need.
      else
        return data
      end
    end

    def toggle_status
      data = model_read(ProductNeed, product_need_id)
    end
  end
end