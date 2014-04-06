require './lib/lynr/controller'
require './lib/lynr/controller/admin'
require './lib/lynr/model/vehicle'

module Lynr; module Controller;

  # # `Lynr::Controller::AdminManageVehicles`
  #
  # Controller to handle requests for the manage vehicles resource.
  #
  class AdminManageVehicles < Lynr::Controller::Admin

    include Lynr::Controller::Paginated

    get  '/admin/:slug/vehicle/manage', :get

    # ## `Admin::Inventory#before_GET(req)`
    #
    # Set controller-wide variables for request handlers.
    #
    def before_GET(req)
      super
      @subsection = 'vehicle-list'
      @title = "Manage Vehicles"
    end

    # ## `AdminManageVehicles#get(req)`
    #
    # Process GET requests for the manage vehicles resource.
    #
    def get(req)
      @pagination_data = {
        current: page(req),
        pages:   page_nums(req, vehicle_count(req)),
        uri:     "/admin/#{dealership(req).slug}/vehicle/manage?page=",
      }
      @vehicles = vehicle_dao.list(dealership(req), page(req), PER_PAGE)
      req.session['back_uri'] = "/admin/#{@dealership.slug}/vehicle/manage"
      render 'admin/vehicle/manage.erb'
    end

  end

end; end;
