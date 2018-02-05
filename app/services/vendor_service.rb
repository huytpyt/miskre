class VendorService
  extend CrudForApi

  class << self

    def create vendor_params, inventory_params
      data = model_create(Vendor, vendor_params)
      vendor = data[:vendor]
      vendor.inventories = Inventory.where(id: eval(inventory_params[:inventories]))
      vendor.save
      model_read(Vendor, vendor.id)
    end

    def update vendor_id, vendor_params, inventory_params
      data = model_update(Vendor, vendor_id, vendor_params)
      vendor = data[:vendor]
      vendor.inventories = Inventory.where(id: eval(inventory_params[:inventories]))
      vendor.save
      model_read(Vendor, vendor.id)
    end

    def show vendor_id
      data = model_read(Vendor, vendor_id)
    end

    def destroy vendor_id
      model_destroy(Vendor, vendor_id)
    end
  end
end