require 'lynr/controller/admin'

module Lynr; module Controller;

  class AdminVehicle < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/add', :get_add

    def get_add(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle vehicle-add'
      @title = 'Add Vehicle'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      render 'admin/vehicle/add.erb'
    end

  end

end; end;
