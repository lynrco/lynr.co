require './lib/lynr'
require './lib/lynr/controller'
require './lib/lynr/controller/admin'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Inventory`
  #
  # Logic for rendering the inventory screen.
  #
  class Admin::Inventory < Lynr::Controller::Admin

    include Lynr::Controller::Paginated

    get  '/admin/:slug', :inventory
    get  '/menu/:slug',  :menu

    # ## `Admin::Inventory#before_GET(req)`
    #
    # Set controller-wide variables for request handlers.
    #
    def before_GET(req)
      super
      @subsection = 'vehicle-list'
      @title = "Welcome back #{dealership(req).name}"
    end

    # ## `Admin::Inventory#inventory(req)`
    #
    # Admin inventory screen. Renders `views/admin/index.erb`.
    #
    def inventory(req)
      @pages = page_nums(req, vehicle_count(req))
      @vehicles = vehicle_dao.list(dealership(req), page(req), PER_PAGE)
      req.session.delete('back_uri')
      render 'admin/index.erb'
    end

    # ## `Admin::Inventory#menu(req)`
    #
    # Primarmy menu shown over the admin inventory screen.
    #
    def menu(req)
      @menu_vis = 'menu-visible-primary'
      inventory(req)
    end

  end

end
