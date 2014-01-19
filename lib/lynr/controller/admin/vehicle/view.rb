require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/vehicle_base'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::View`
  #
  # Handle requests for vehicle view inside the admin pages.
  #
  class Admin::Vehicle::View < Lynr::Controller::Admin::Vehicle

    get  '/admin/:slug/:vehicle', :get_html

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

  end

end
