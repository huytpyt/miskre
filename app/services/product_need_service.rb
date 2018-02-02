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

    def toggle_status product_need_id
      data = model_read(ProductNeed, product_need_id)
      product_need = data[:product_need]
      if product_need
        if product_need.running?
          product_need.suspend!
        elsif product_need.suspend?
          product_need.running!
        end
      end
      return model_read(ProductNeed, product_need_id)
    end
  end
end