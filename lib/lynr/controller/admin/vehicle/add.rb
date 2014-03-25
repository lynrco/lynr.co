require './lib/lynr'
require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/vehicle'
require './lib/lynr/model/vehicle'
require './lib/lynr/queue/index_vehicle_job'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::Add`
  #
  # Handle requests for vehicle add inside the admin pages.
  #
  class Admin::Vehicle::Add < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/add', :get_html
    post '/admin/:slug/vehicle/add', :post_html

    # ## `Vehicle::Add#before_POST(req)`
    #
    # Set `@posted` to be a copy of the data posted in the request. Set 'dealership'
    # in posted data to the current dealership.
    #
    def before_POST(req)
      super
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
      Lynr.producer('job').publish(Lynr::Queue::IndexVehicleJob.new(vehicle))
      redirect "/admin/#{@dealership.slug}/#{vehicle.slug}/edit"
    end

  end

end
