require 'lynr/controller/admin'
require 'lynr/model/vehicle'

module Lynr; module Controller;

  class AdminManageVehicles < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/manage', :get

    def get(req)
      return unauthorized unless authorized?(req)
      @subsection = "vehicle vehicle-list"
      @title = "Manage Vehicles"
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicles = vehicle_dao.list(@dealership)
      render 'admin/vehicle/manage.erb'
    end

  end

end; end;
