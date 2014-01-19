require 'json'

require './lib/lynr/controller/admin/vehicle'
require './lib/lynr/model/sized_image'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::Photos`
  #
  # Handle requests for vehicle photos management
  #
  class Admin::Vehicle::Photos < Lynr::Controller::Admin::Vehicle

    get  '/admin/:slug/:vehicle/photos', :get_edit_vehicle_photos
    post '/admin/:slug/:vehicle/photos', :post_edit_vehicle_photos

    def initialize
      super
      @subsection = 'vehicle-edit'
    end

    def get_edit_vehicle_photos(req)
      @title = "Photos for #{@vehicle.name}"
      params = transloadit_params('vehicle_template_id')
      @transloadit_params = params.to_json
      @transloadit_params_signature = transloadit_params_signature(params)
      render 'admin/vehicle/photos.erb'
    end

    def post_edit_vehicle_photos(req)
      posted['images'] = JSON.parse(posted['images']).map do |image|
        Lynr::Model::SizedImage.inflate(image)
      end
      vehicle_dao.save(@vehicle.set(posted))
      redirect "/admin/#{@dealership.slug}/#{@vehicle.slug}/edit"
    end

  end

end
