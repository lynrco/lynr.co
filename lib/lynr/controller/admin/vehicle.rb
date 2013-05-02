require 'lynr/controller/admin'
require 'lynr/model/vehicle'

module Lynr; module Controller;

  class AdminVehicle < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/add', :get_add
    post '/admin/:slug/vehicle/add', :post_add
    get  '/admin/:slug/:vehicle',    :get_vehicle

    def get_add(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle vehicle-add'
      @title = 'Add Vehicle'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      render 'admin/vehicle/add.erb'
    end

    def post_add(req)
      return unauthorized unless authorized?(req)
      dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST.dup
      posted['dealership'] = @dealership
      vehicle = vehicle_dao.save(Lynr::Model::Vehicle.inflate(posted))
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}"
    end

    def get_vehicle(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle vehicle-add'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "Edit #{@vehicle.year} #{@vehicle.make} #{@vehicle.model}"
      @posted = @vehicle.view
      render 'admin/vehicle/edit.erb'
    end

  end

end; end;
