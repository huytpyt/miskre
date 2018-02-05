module CrudForApi
  extend ActiveSupport::Concern

  def model_create model, params
    object = model.new(params)
    if object.valid?
      object.save
      return convert_to_json("Success", object, nil, model)
    else
      return convert_to_json("Failed", nil, object.errors.messages, model)
    end
  end

  def model_read model, object_id
    object = model.where(id: object_id).first
    if object
      return convert_to_json("Success", object, nil, model)
    else
      return convert_to_json("Failed", nil, "Can not find #{model.to_s} with id #{object_id}", model)
    end
  end

  def model_update model, object_id, params
    data = model_read(model, object_id)
    object = data["#{model.to_s.underscore}".to_sym]
    if object
      object.assign_attributes(params)
      if object.valid?
        object.save
        return convert_to_json("Success", object, nil, model)
      else
        return convert_to_json("Failed", nil, object.errors.messages, model)
      end
    else
      return data
    end
  end

  def model_destroy model, object_id
    data = model_read(model, object_id)
    object = data["#{model.to_s.underscore}".to_sym]

    if object
      object.destroy
      return convert_to_json("Success", nil, nil, model)
    else
      return convert_to_json(result, object, errors, model)
    end
  end

  private

  def convert_to_json result, object, errors, model
    { result: result, "#{model.to_s.underscore}": object, errors: errors }
  end
 end