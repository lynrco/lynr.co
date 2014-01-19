require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/vehicle'
require './lib/lynr/model/vehicle'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::Add`
  #
  # Handle requests for vehicle add inside the admin pages.
  #
  class Admin::Vehicle::Add < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/add', :get_html
    post '/admin/:slug/vehicle/add', :post_html

    # ## `Vehicle::Add#before_each(req)`
    #
    # Check the user is allowed to add vehicles and setup the `@dealership`
    # property.
    #
    def before_each(req)
      super
      return unauthorized unless authorized?(req)
      @dealership = session_user(req)
    end

    # ## `Vehicle::Add#before_POST(req)`
    #
    # Set `@posted` to be a copy of the data posted in the request. Set 'dealership'
    # in posted data to the current dealership.
    #
    def before_POST(req)
      super
      @posted = req.POST.dup
      posted['dealership'] = session_user(req)
    end

    # ## `Vehicle::Add#get_html(req)`
    #
    # Get an HTML representation of the `Vehicle::Add` resource for `req`
    #
    def get_html(req)
      @subsection = 'vehicle-add'
      @title = 'Add Vehicle'
      render 'admin/vehicle/add.erb'
    end

    # ## `Vehicle::Add#get_html(req)`
    #
    # Create a new vehicle for the data provided in `req` and return an
    # HTML view of the vehicle by redirecting to the edit page.
    #
    def post_html(req)
      vehicle = vehicle_dao.save(Lynr::Model::Vehicle.inflate(@posted))
      redirect "/admin/#{@dealership.slug}/#{vehicle.slug}/edit"
    end

  end

end
