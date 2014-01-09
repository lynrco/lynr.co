module Lynr::Controller

  class Ebay::Failure < Lynr::Controller::Base

    get  '/auth/ebay/failure', :get

    def initialize
      super
      @title = "Callback Failure"
    end

    def get(req)
      render 'auth/ebay/failure.erb', layout: 'default.erb'
    end

  end

end
