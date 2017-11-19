class Api::V1::ProductsController < Api::V1::BaseController
  before_action :staff_authentication
  before_action :prepare_product, only: [:show, :update, :destroy]

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Product.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    render json: ProductsQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def show
    render json: ProductsQuery.single(@product), status: 200
  end

  def create
    ActiveRecord::Base.transaction do
      if params[:product]
        product = Product.new(product_params)
        if product.save
          if params[:product][:images].present?
            if params[:product][:images].is_a?(Array)
              exists_ids = params[:product][:images].select{|id| Image.exists?(id)}
              product.image_ids = exists_ids
              product.save!
              render json: ProductsQuery.single(product), status: 200
            else
              render json: {status: false, error: "`images` must an array"}, status: 500
            end
          else
            render json: ProductsQuery.single(product), status: 200
          end
        else
          render json: {status: false, error: product.errors.full_messages}, status: 500
        end
      else
        render json: {status: false, error: "The params invalid!"}, status: 500
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if params[:product]
        if params[:product].empty?
          render json: ProductsQuery.single(@product), status: 200
        else
          if @product.update(product_params)
            if params[:product][:images].present?
              if params[:product][:images].is_a?(Array)
                exists_ids = params[:product][:images].select{|id| Image.exists?(id)}
                @product.image_ids = exists_ids
                @product.save
                render json: ProductsQuery.single(@product), status: 200
              else
                render json: {status: false, error: "`images` must an array"}, status: 500
              end
            else
              render json: ProductsQuery.single(@product), status: 200
            end
          else
            render json: {status: false, error: @product.errors.full_messages}, status: 500
          end
        end
      else
        render json: {status: false, error: "The params invalid!"}, status: 500
      end
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

    def prepare_product
      @product = Product.find(params[:id])
    end

    def staff_authentication
      unless current_resource.staff?
        render json: {status: false, message: "Permission denied"}, status: 550
      end
    end

    def product_params
      params.require(:product).permit(
        :name,
        :weight,
        :length,
        :height,
        :width,
        :desc,
        :price,
        :cost,
        :link,
        :quantity,
        :product_ids,
        :product_url,
        :suggest_price,
        :sale_off
      )
    end
end
