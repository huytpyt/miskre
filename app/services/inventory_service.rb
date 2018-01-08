class InventoryService
  class << self
    def create params
      product_id = params[:product_id].to_i
      quantity = params[:quantity].to_i
      cost = params[:cost].to_f

      inventory = Inventory.new(
        product_id: product_id,
        quantity: quantity,
        cost: cost)

      if inventory.valid?
        inventory.save
        return ["Success", nil, inventory]
      else
        return ["Failed", inventory.errors.messages, nil]
      end
    end

    def update inventory_id, inventory_params
      inventory = Inventory.where(id: inventory_id).first
      if inventory
        inventory.assign_attributes(inventory_params)
        if inventory.valid?
          inventory.save
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
