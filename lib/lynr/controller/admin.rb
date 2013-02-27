require './lib/lynr/controller/base'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  class Admin < Lynr::Controller::Base

    map '/admin'

    layout :mobile_default

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Automagically renders `views/admin/index.erb` based on the
    # mapping and method name servicing the request, in this case `index`
    def index
      @title = "Hi there Admin!"
    end

  end

end; end;
