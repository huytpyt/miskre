class Api::V1::ProductsController < Api::V1::BaseController
  before_action :staff_authentication, only: [:create, :destroy]
  before_action :staff_partner_authentication, only: [:index, :show, :update]
  before_action :admin_authentication, only: [:toggle_approve]
  before_action :prepare_product, only: [:show, :update, :destroy, :toggle_approve]

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    key = params[:key] || nil
    render json: ProductsQuery.list(page, per_page, sort, order_by, search, key, current_resource), status: 200
  end

  def show
    render json: current_resource.partner? ? ProductsQuery.single_partner(@product) : ProductsQuery.single(@product), status: 200
  end

  def create
    ActiveRecord::Base.transaction do
      if params[:product]
        product = Product.new(product_params)
        if params[:product][:cost_per_quantity].present?
          product.cost_per_quantity = params[:product][:cost_per_quantity]
        end
        if product.save
          if params[:product][:categories].present?
            if params[:product][:categories].is_a?(Array)
              exists_ids = params[:product][:categories].select{|category| Category.exists?(category)}
              product.categories = Category.where(id: exists_ids)
              product.save!
            else
              render json: {status: false, error: "`categories` must an array"}, status: 500
            end
          end
          if params[:product][:images].present?
            if params[:product][:images].is_a?(Array)
              exists_ids = params[:product][:images].select{|image| Image.exists?(image[:id])}
              product.image_ids = exists_ids.pluck(:id)
              product.save!
            else
              render json: {status: false, error: "`images` must an array"}, status: 500
            end
          end
          if params[:product][:resource_images].present?
            if params[:product][:resource_images].is_a?(Array)
              exists_ids = params[:product][:resource_images].select{|image| ResourceImage.exists?(image[:id])}
              product.resource_image_ids = exists_ids.pluck(:id)
              product.save!
            else
              render json: {status: false, error: "`images` must an array"}, status: 500
            end
          end
          if params[:product][:options].present?
            if params[:product][:options].is_a?(Array)
              params[:product][:options].each do |option|
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
    @price_change = false
    ActiveRecord::Base.transaction do
      if params[:product]
        if params[:product].empty?
          render json: ProductsQuery.single(@product), status: 200
        else
          if params[:product][:cost_per_quantity].present?
            @product.cost_per_quantity = params[:product][:cost_per_quantity]
            @product.save
          end
          @product.assign_attributes(current_resource.partner? ? partner_product_params : product_params)
          unless current_resource.partner?
            if @product.suggest_price_changed?
              @price_change = true
              random = rand(2.25 .. 2.75)
              new_compare_at_price = (@product.suggest_price * random/ 5).round(0) * 5
              @product.variants.each do | variant|
                variant.update(price: @product.suggest_price, compare_at_price: new_compare_at_price)
              end
            end
          end
          if @product.save
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
            if current_resource.staff?
              if params[:product][:supply].nil?
                if params[:product][:categories].present?
                  if params[:product][:categories].is_a?(Array)
                    exists_ids = params[:product][:categories].select{|category| Category.exists?(category)}
                    @product.categories = Category.where(id: exists_ids)
                    @product.save!
                  else
                    render json: {status: false, error: "`categories` must an array"}, status: 500
                  end
                end
                if params[:product][:resource_images].present?
                  if params[:product][:resource_images].is_a?(Array)
                    exists_ids = params[:product][:resource_images].select{|image| ResourceImage.exists?(image[:id])}
                    @product.resource_image_ids = exists_ids.pluck(:id)
                    @product.save!
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
                  unless @price_change
                    if params[:product][:variants].present?
                      if params[:product][:variants].is_a?(Array)
                        vts = []
                        params[:product][:variants].each do |variant|
                          variant_id = variant[:id]
                          if variant_id
                            vt = Variant.find(variant_id)
                            if vt
                              vt.quantity = variant[:quantity]
                              vt.price = variant[:price]
                              if variant[:image].present?
                                exists_ids = Image.exists?(variant[:image][:id]) ? [variant[:image][:id]] : []
                                vt.image_ids = exists_ids
                              end
                              vt.save
                              vts << vt.id
                            end
                          end
                        end
                        @product.variants.where.not(id: vts).destroy_all
                      else
                        render json: {status: false, error: "`variants` must an array"}, status: 500
                      end
                    end
                  end
                else
                  @product.options.destroy_all
                  @product.variants.destroy_all
                end
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

  def toggle_approve
    if @product.approved
      @product.approved = false
    else
      @product.approved = true
    end
    if @product.save
      render json: {approved: @product.approved}, status: 200
    else
      render json: {error: @product.errors.full_messages}, status: 500
    end
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

    def staff_partner_authentication
      unless current_resource.staff? || current_resource.partner?
        render json: {status: false, message: "Permission denied"}, status: 550
      end
    end

    def admin_authentication
      unless current_resource.admin?
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
        :vendor_detail,
        :purchase_link,
        :china_name
      )
    end

    def partner_product_params
      params.require(:product).permit(
        :weight,
        :length,
        :height,
        :width,
        :desc,
        :link,
        :vendor_detail
      )
    end
end
