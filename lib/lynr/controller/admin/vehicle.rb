require 'lynr/controller/admin'
require 'lynr/model/vehicle'
require 'lynr/model/sized_image'
require 'lynr/view/menu'

module Lynr; module Controller;

  class AdminVehicle < Lynr::Controller::Admin

    get  '/admin/:slug/:vehicle',        :get_vehicle
    get  '/admin/:slug/vehicle/add',     :get_add
    post '/admin/:slug/vehicle/add',     :post_add
    get  '/admin/:slug/:vehicle/edit',   :get_edit_vehicle
    post '/admin/:slug/:vehicle/edit',   :post_edit_vehicle
    get  '/admin/:slug/:vehicle/menu',   :get_vehicle_menu
    get  '/admin/:slug/:vehicle/photos', :get_edit_vehicle_photos
    post '/admin/:slug/:vehicle/photos', :post_edit_vehicle_photos

    def initialize
      super
      @base_menu = Lynr::View::Menu.new('Vehicle Menu', "", :menu_vehicle)
    end

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

    # Handle view vehicle
    def get_vehicle(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle-view'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "#{@vehicle.name}"
      @menu_secondary = @base_menu.set_href("/admin/#{@dealership.slug}/#{@vehicle.slug}/menu")
      render 'admin/vehicle/view.erb'
    end

    def get_vehicle_menu(req)
      @menu_vis = 'menu-visible-secondary'
      get_vehicle(req)
    end

    # Handle add vehicle
    def get_add(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle-add'
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
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}/edit"
    end

    # Handle edit vehicle
    def get_edit_vehicle(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle-edit'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "Edit #{@vehicle.name}"
      @menu_secondary = @base_menu.set_href("/admin/#{@dealership.slug}/#{@vehicle.slug}/menu")
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
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}/edit"
    end

    # Handle edit photos
    def get_edit_vehicle_photos(req)
      return unauthorized unless authorized?(req)
      @subsection = 'vehicle-photos'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle']))
      @title = "Photos for #{@vehicle.name}"
      @menu_secondary = @base_menu.set_href("/admin/#{@dealership.slug}/#{@vehicle.slug}/menu")
      @posted = @vehicle.view
      @transloadit_params = {
        auth: { key: Lynr::Web.config['transloadit']['auth_key'] },
        template_id: Lynr::Web.config['transloadit']['vehicle_template_id']
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
      redirect "/admin/#{dealership.slug}/#{vehicle.slug}/edit"
    end

  end

end; end;
