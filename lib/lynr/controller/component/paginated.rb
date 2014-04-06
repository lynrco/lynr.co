require './lib/lynr/controller'

module Lynr::Controller

  module Paginated

    PER_PAGE = 10
    SPREAD   =  2

    def last_page(count)
      (count / PER_PAGE.to_f).ceil
    end

    def page(req)
      req.params.fetch('page', default='1').to_i
    end

    def page_nums(req, count)
      first = page(req) - SPREAD
      last = bound_first(first) + (SPREAD * 2)
      first = bound_last(last, count) - (SPREAD * 2) if bound_last(last, count) == last_page(count)
      bound_first(first)..bound_last(last, count)
    end

    private

    def bound_first(first)
      if first < 1 then 1 else first end
    end

    def bound_last(last, count)
      if last > last_page(count) then last_page(count) else last end
    end

  end

end
