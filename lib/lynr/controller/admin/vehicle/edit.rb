require './lib/lynr'
require './lib/lynr/controller/admin/vehicle'
require './lib/lynr/model/mpg'
require './lib/lynr/queue/index_vehicle_job'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::Edit`
  #
  # Handle requests for vehicle editing
  #
  class Admin::Vehicle::Edit < Lynr::Controller::Admin::Vehicle

    get  '/admin/:slug/:vehicle/edit',   :get_edit_vehicle
    post '/admin/:slug/:vehicle/edit',   :post_edit_vehicle

    def initialize
      super
      @subsection = 'vehicle-edit'
    end

    def get_edit_vehicle(req)
      @title = "Edit #{@vehicle.name}"
      render 'admin/vehicle/edit.erb'
    end

    def post_edit_vehicle(req)
      # Need to inflate the Mpg and Vin views that come from posted data
      posted['mpg'] = Lynr::Model::Mpg.inflate(posted['mpg'])
      posted['vin'] = @vehicle.vin.set(posted['vin'])
      save_vehicle(@vehicle.set(posted))
      redirect "/admin/#{@dealership.slug}/#{@vehicle.slug}"
    end

  end

end
