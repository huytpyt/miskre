class BaseQuery
  LIMIT_RECORDS = 20
  DEFAULT_PAGE  = 1
  SORT_OPTIONS  = {id: :desc}

  class << self
    include ApplicationHelper

    def paginate(collection, page_number, n = 20)
      collection.page(page_number).per(n)
    end

    def paginate_array(collection, page_number, n = 20)
      Kaminari.paginate_array(collection).page(page_number).per(n)
    end

    def api_paginate(collection, page)
    	collection.page(page)
    end
  end
end
