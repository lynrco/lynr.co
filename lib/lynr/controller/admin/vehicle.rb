require 'lynr/controller/admin'
require 'lynr/model/vehicle'
require 'lynr/model/sized_image'

module Lynr; module Controller;

  class AdminVehicle < Lynr::Controller::Admin

    get  '/admin/:slug/vehicle/add',     :get_add
    post '/admin/:slug/vehicle/add',     :post_add
    get  '/admin/:slug/:vehicle',        :get_edit_vehicle
    post '/admin/:slug/:vehicle',        :post_edit_vehicle
    get  '/admin/:slug/:vehicle/photos', :get_edit_vehicle_photos
    post '/admin/:slug/:vehicle/photos', :post_edit_vehicle_photos

    # TODO: This doesn't do anything but it should be possible to make it
    # The same logic is repeated in every handling method
    def self.before(req)
      response = nil
      response = unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      response = not_found if @dealership.nil? or @vehicle.nil?
      response
    end

    # Handle add vehicle
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
      posted['dealership'] = dealership
      vehicle = vehicle_dao.save(Lynr::Model::Vehicle.inflate(@posted))
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}"
    end

    # Handle edit vehicle
    def get_edit_vehicle(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle vehicle-edit'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "Edit #{@vehicle.year} #{@vehicle.make} #{@vehicle.model}"
      @posted = @vehicle.view
      render 'admin/vehicle/edit.erb'
    end

    def post_edit_vehicle(req)
      return unauthorized unless authorized?(req)
      dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @posted = req.POST.dup
      posted['dealership'] = dealership
      # Need to inflate the Mpg and Vin views that come from posted data
      posted['mpg'] = Lynr::Model::Mpg.inflate(posted['mpg'])
      posted['vin'] = Lynr::Model::Vin.inflate(posted['vin'])
      vehicle_dao.save(vehicle.set(posted))
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}"
    end

    # Handle edit photos
    def get_edit_vehicle_photos(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle vehicle-photos'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "Photos for #{@vehicle.year} #{@vehicle.make} #{@vehicle.model}"
      @posted = @vehicle.view
      @transloadit_params = {
        auth: { key: Lynr::App.config['transloadit']['auth_key'] },
        template_id: Lynr::App.config['transloadit']['vehicle_template_id']
      }.to_json
      render 'admin/vehicle/photos.erb'
    end

    def post_edit_vehicle_photos(req)
      return unauthorized unless authorized?(req)
      dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @posted = req.POST.dup
      posted['dealership'] = dealership
      posted['images'] = JSON.parse(posted['images']).map { |image| Lynr::Model::SizedImage.inflate(image) }
      vehicle_dao.save(vehicle.set(posted))
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}"
    end

  end

end; end;
