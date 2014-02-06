require './lib/lynr/model/token'
require './lib/lynr/persist/dao'

module Lynr::Controller

  class Auth::Forgot < Lynr::Controller::Auth

    get  '/signin/forgot',  :get_forgot

    def get_forgot(req)
      @subsection = "forgot"
      @title = "Forgot Password"
      render 'auth/forgot.erb'
    end

  end

end
