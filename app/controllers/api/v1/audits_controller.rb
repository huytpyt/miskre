class Api::V1::AuditsController < Api::V1::BaseController

  def money_log
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Audit.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    key = params[:key] || nil
    if current_resource.staff?
      render json: AuditQuery.list(page, per_page, sort, order_by, search, key, "money_log")
    else
      render json: { error: "Permission denied"}
    end
  end

  def product_log
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Audit.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    key = params[:key] || nil
    if current_resource.staff?
      render json: AuditQuery.list(page, per_page, sort, order_by, search, key, "product_log")
    else
      render json: { error: "Permission denied"}
    end
  end
end
