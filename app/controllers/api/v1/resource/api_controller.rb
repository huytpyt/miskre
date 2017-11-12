class Api::V1::Resource::ApiController < ::Api::V1::BaseController

  def scope
    params[:scope].try(:to_sym)
  end

  def scoped_resource_name
    scoped_resource_class.name.underscore.to_sym
  end

  def scoped_resource_class
    scope.to_s.classify.constantize
  end

end
