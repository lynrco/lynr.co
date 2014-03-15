require './lib/lynr'
require './lib/lynr/controller/admin'

module Lynr::Controller

  class Admin::Support < Lynr::Controller::Admin

    get  '/admin/:slug/support', :get

    def before_each(req)
      super
      @title = "Lynr.co Support"
      @subsection = "support"
    end

    def get(req)
      render 'admin/support'
    end

  end

end
