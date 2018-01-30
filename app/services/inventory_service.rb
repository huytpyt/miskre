class InventoryService
  class << self
    def create params, inventory_variant_params
      product_id = params[:product_id].to_i
      quantity = params[:quantity].to_i
      cost = params[:cost].to_f

      inventory = Inventory.new(
        product_id: product_id,
        quantity: quantity,
        in_stock: quantity,
        cost: cost)

      if inventory.valid?
        ActiveRecord::Base.transaction do
          inventory.save
          if inventory_variant_params
            variants = eval(inventory_variant_params[:variants])
            variants.each do |item|
              InventoryVariant.create(
                inventory_id: inventory.id,
                variant_id:item[:variant_id],
                cost: item[:cost],
                quantity: item[:quantity]
                )
            end
          end
        end
        return ["Success", nil, inventory]
      else
        return ["Failed", inventory.errors.messages, nil]
      end
    end

    def update inventory_id, inventory_params, inventory_variant_params
      inventory = Inventory.where(id: inventory_id).first
      if inventory
        inventory.assign_attributes(inventory_params)
        if inventory.valid?
          ActiveRecord::Base.transaction do
            inventory.save
            if inventory_variant_params
              variants = eval(inventory_variant_params[:variants])
              variants.each do |item|
                inventory_variant = InventoryVariant.find_or_initialize_by(inventory_id: item[:inventory_id], variant_id: item[:variant_id])
                inventory_variant.assign_attributes(item)
                inventory_variant.save
              end
            end
          end
          return [ "Success", nil, inventory]
        else
          [ "Failed", inventory.errors.messages, inventory]
        end
      else
        return [ "Failed", "Can not find inventory with id #{inventory_id}", nil]
      end
    end

    def destroy inventory_id
      inventory = Inventory.where(id: inventory_id).first
      if inventory
        inventory.destroy
        return [ "Success", nil, nil]
      else
        [ "Failed", "Can not find inventory with id #{inventory_id}", nil ]
      end
    end

  end
end
