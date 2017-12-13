class AuditQuery < BaseQuery
  def self.list(page, per_page, sort, order_by, search, key)
    sort_options = { "#{order_by}" => sort }
    audits = Audit.all
    if audits.blank?
      {
        logs: []
      }
    else
      paginate = api_paginate(audits.order(sort_options).search(search), page).per(per_page)
      {
        paginator: {
          total_records: paginate.total_count,
          records_per_page: paginate.limit_value,
          total_pages: paginate.total_pages,
          current_page: paginate.current_page,
          next_page: paginate.next_page,
          prev_page: paginate.prev_page,
          first_page: 1,
          last_page: paginate.total_pages
        },
        logs: paginate.map{ |audit| single(audit) }
      }
    end
  end

  def self.single audit
    {
      id: audit.id,
      model: audit.auditable_type,
      associated_model: audit.associated_type,
      associated_model_id: audit.associated_id,
      user_id: audit.user_id,
      user_type: audit.user_type,
      username: audit.username,
      action: audit.action,
      audited_changes: audit.audited_changes,
      version: audit.version,
      comment: audit.comment,
      remote_address: audit.remote_address,
      request_uuid: audit.request_uuid,
      created_at: audit.created_at
    }
  end
end