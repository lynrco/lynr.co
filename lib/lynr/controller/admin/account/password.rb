require './lib/lynr'
require './lib/lynr/controller/admin'

module Lynr::Controller

  class AdminAccountPassword < Lynr::Controller::Admin

    get  '/admin/:slug/account/password', :get

    def get(req)
      @subsection = 'account account-password'
      @title = "Change Password"
      render 'admin/account/password.erb'
    end

  end

end
