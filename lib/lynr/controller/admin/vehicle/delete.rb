require './lib/lynr/controller/admin/vehicle'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle::Delete`
  #
  # Handle requests for vehicle deletion
  #
  class Admin::Vehicle::Delete < Lynr::Controller::Admin::Vehicle

    get  '/admin/:slug/:vehicle/delete', :get_delete_vehicle
    post '/admin/:slug/:vehicle/delete', :post_delete_vehicle

    def initialize
      super
      @subsection = 'vehicle-delete'
    end

    def get_delete_vehicle(req)
      @title = "Delete #{@vehicle.name}"
      render 'admin/vehicle/delete.erb'
    end

    def post_delete_vehicle(req)
      posted['deleted_at'] = Time.now
      vehicle_dao.save(@vehicle.set(posted))
      # `@back_uri` is set in `Lynr::Controller::Admin::Vehicle`
      redirect @back_uri
    end

  end

end
