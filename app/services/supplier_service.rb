class SupplierService
  class << self
    def update supplier_params, user_id
      supplier = Supplier.where(user_id: user_id).first
      if supplier
        supplier.assign_attributes(supplier_params)
        if supplier.valid?
          supplier.save
          return [ "Success", nil, supplier]
        else
          [ "Failed", supplier.errors.messages, supplier]
        end
      else
        return [ "Failed", "Can not find supplier with user_id #{supplier}", nil]
      end
    end

  end
end