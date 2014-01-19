require './lib/lynr/controller/admin/vehicle'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::View`
  #
  # Handle requests for vehicle view inside the admin pages.
  #
  class Admin::Vehicle::View < Lynr::Controller::Admin::Vehicle

    get  '/admin/:slug/:vehicle',       :get_html
    get  '/admin/:slug/:vehicle/menu',  :get_html_menu

    # ## `Vehicle::View#get_html(req)`
    #
    # Process request and render the html view for vehicle inside admin.
    #
    def get_html(req)
      @subsection = 'vehicle-view'
      @title = "#{@vehicle.name}"
      log.info('type=measure.render template=admin/vehicle/view.erb')
      render 'admin/vehicle/view.erb'
    end

    # ## `Vehicle::View#get_html_menu(req)`
    #
    # Process request and render the html view for vehicle inside admin with
    # menu visible by default.
    #
    def get_html_menu(req)
      @menu_vis = 'menu-visible-secondary'
      get_vehicle(req)
    end

  end

end
