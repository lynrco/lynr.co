require './lib/lynr/controller/base'
require './lib/lynr/persist/dealership_dao'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  class Admin < Lynr::Controller::Base

    map '/admin'

    layout :mobile_default

    def initialize
      # Let Ramaze do its thing
      super
      # Set up the controller
      @dao = Lynr::Persist::DealershipDao.new
    end

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Automagically renders `views/admin/index.erb` based on the
    # mapping and method name servicing the request, in this case `index`
    def index(slug='default')
      # Setting instance variables for templates to access makes me very nervous
      # TODO: Find some kind of confirmation that Rack applications are single threaded.
      @title = "Hi there Admin!"
      @owner = "CarMax"
    end

  end

end; end;
