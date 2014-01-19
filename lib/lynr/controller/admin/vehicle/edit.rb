require './lib/lynr/controller/admin/vehicle_base'

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
      posted['vin'] = Lynr::Model::Vin.inflate(posted['vin'])
      vehicle_dao.save(@vehicle.set(posted))
      redirect "/admin/#{@dealership.slug}/#{@vehicle.slug}/edit"
    end

  end

end
