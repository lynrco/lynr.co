require './lib/lynr/controller'

module Lynr::Controller

  module Paginated

    PER_PAGE = 10

    def page(req)
      req.params.fetch('page', default='1').to_i
    end

  end

end
