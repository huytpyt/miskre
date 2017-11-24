class Api::V1::ProductsController < Api::V1::BaseController
  before_action :staff_authentication
  before_action :prepare_product, only: [:show, :update, :destroy]

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Product.where(shop_owner: false).count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    key = params[:key] || nil
    render json: ProductsQuery.list(page, per_page, sort, order_by, search, key), status: 200
  end

  def show
    render json: ProductsQuery.single(@product), status: 200
  end

  def create
    ActiveRecord::Base.transaction do
      if params[:product]
        product = Product.new(product_params)
        if params[:product][:cost_per_quantity].present?
          product.cost_per_quantity = params[:product][:cost_per_quantity]
        end
        if product.save
          if params[:product][:images].present?
            if params[:product][:images].is_a?(Array)
              exists_ids = params[:product][:images].select{|id| Image.exists?(id)}
              product.image_ids = exists_ids
              product.save!
            else
              render json: {status: false, error: "`images` must an array"}, status: 500
            end
          end

          if params[:product][:options].present?
            if params[:product][:options].is_a?(Array)
              params[:product][:options].each do |option|
                # option[:values] = option[:values].split(",")
                if option[:name].present?
                  opt = product.options.new(name: option[:name], values: option[:values])
                  opt.save!
                end
              end
              product.regen_variants
            else
              render json: {status: false, error: "`options` must an array"}, status: 500
            end
          end

          render json: ProductsQuery.single(product), status: 200
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
          if params[:product][:cost_per_quantity].present?
            @product.update(cost_per_quantity: params[:product][:cost_per_quantity])
          end
          if @product.update(product_params)
            if params[:product][:images].present?
              if params[:product][:images].is_a?(Array)
                exists_ids = []
                params[:product][:images].each do |image|
                  if Image.exists?(image[:id])
                    exists_ids.push(image[:id])
                  end
                end
                @product.image_ids = exists_ids
                @product.save
              else
                render json: {status: false, error: "`images` must an array"}, status: 500
              end
            end

            if params[:product][:options].present?
              if params[:product][:options].is_a?(Array)
                opts = []
                params[:product][:options].each do |option|
                  option_id = option[:id]
                  if option_id
                    opt = Option.find(option_id)
                    if opt
                      opt.name = option[:name] if option[:name].present?
                      opt.values = option[:values] if option[:values].present?
                      opt.save if opt.changed?
                    end
                  else
                    opt = @product.options.create!(name: option[:name], values: option[:values])
                  end
                  opts << opt.id
                end
                @product.options.where.not(id: opts).destroy_all
              else
                render json: {status: false, error: "`options` must an array"}, status: 500
              end
            end

            if params[:product][:variants].present?
              if params[:product][:variants].is_a?(Array)
                vts = []
                params[:product][:variants].each do |variant|
                  variant_id = variant[:id]
                  if variant_id
                    vt = Variant.find(variant_id)
                    if vt
                      vt.option1 = variant[:option1].present?
                      vt.option2 = variant[:option2].present?
                      vt.option3 = variant[:option3].present?
                      vt.quantity = variant[:quantity].present?
                      vt.price = variant[:price].present?
                      if variant[:images].present?
                        if variant[:images].is_a?(Array)
                          exists_ids = variant[:images].select{|id| Image.exists?(id)}
                          vt.image_ids = exists_ids
                          vt.save
                        end
                      end
                      vt.save if vt.changed?
                      vts << vt.id
                    end
                  end
                end
                @product.variants.where.not(id: vts).destroy_all
              else
                render json: {status: false, error: "`variants` must an array"}, status: 500
              end
            end

            render json: ProductsQuery.single(@product), status: 200
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
        :sale_off,
        :resource_url,
        :vendor_detail
      )
    end
end
