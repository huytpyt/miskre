class Api::V1::SuppliesController < Api::V1::BaseController
  load_and_authorize_resource :supply

  def show
    render json: {supply: show_supply(@supply)}, status: 200
  end

  def update
      @supply.attributes = supply_params
      if @supply.price_changed? || @supply.compare_at_price_changed?
        @supply.supply_variants.each do | variant|
          variant.update(price: @supply.price, compare_at_price: @supply.compare_at_price)
        end
      end
      if @supply.update(supply_params)
        if params[:images]
          params[:images].each do |img|
            @supply.images.create(file: img)
          end
        end
        render json: {supply: show_supply(@supply)}, status: 200
      else
        render json: {error: "Something went wrong!"}, status: 500
      end
  end

  def destroy
    shop = @supply.shop
    @supply.is_deleted = true
    @supply.shop_id = nil
    if @supply.save
      JobsService.delay.remove_shopify_product shop.id, @supply.shopify_product_id
      head :no_content
    else
      render json: {error: "Something went wrong!"}, status: 500
    end
  end

  def upload_image_url
    image = @supply.images.new
    image.file_remote_url= params[:url]
    if image.save
      render json: {image: image}, status: 200
    else
      render json: {error: "Check image URL"}, status: 500
    end
  end

  private

  def supply_params
    params.permit(:name, :price, :desc, :original, :keep_custom, :compare_at_price)
  end

  def show_supply supply
    {id: supply.id, name: supply.name, price: supply.price, compare_at_price: supply.compare_at_price, product_id: supply.product_id, shop_id: supply.shop_id, created_at: supply.created_at, updated_at: supply.updated_at, desc: supply.desc, original: supply.original, epub: supply.epub, cost_epub: supply.cost_epub, cost: supply.cost, keep_custom: supply.keep_custom, is_deleted: supply.is_deleted, images: supply.images, variant: supply.supply_variants, product: supply.product}
  end

end