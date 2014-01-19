require './lib/lynr/controller/admin'
require './lib/lynr/model/vehicle'

module Lynr; module Controller;

  # # `Lynr::Controller::AdminManageVehicles`
  #
  # Controller to handle requests for the manage vehicles resource.
  #
  class AdminManageVehicles < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/manage', :get

    # ## `AdminManageVehicles#get(req)`
    #
    # Process GET requests for the manage vehicles resource.
    #
    def get(req)
      @subsection = "vehicle-list"
      @title = "Manage Vehicles"
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicles = vehicle_dao.list(@dealership)
      render 'admin/vehicle/manage.erb'
    end

  end

end; end;
