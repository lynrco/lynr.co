require 'bson'

require './lib/lynr/controller/admin'
require './lib/lynr/converter/number_translator'
require './lib/lynr/converter/vehicle_translator'
require './lib/lynr/converter/vin_translator'
require './lib/lynr/view/menu'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Vehicle`
  #
  # Base controller for vehicle related resources located in the admin pages.
  #
  class Admin::Vehicle < Lynr::Controller::Admin

    # ## `Admin::Vehicle.new`
    #
    # Initialize re-usable properties for vehicle controllers.
    #
    def initialize
      super
      @vehicle = false
    end

    # ## `Admin::Vehicle#before_each(req)`
    #
    # Make sure the user is authorized to view this page and that the dealership
    # and vehicle combination exists before setting up instance properties.
    #
    def before_each(req)
      super
      return not_found unless vehicle(req)
      @vehicle = vehicle(req)
      @back_uri = req.session['back_uri'] || "/admin/#{dealership(req).slug}"
    end

    # ## `Admin::Vehicle#before_GET(req)`
    #
    # Set `@posted` to be a `@vehicle#view` so templates can be rendered the same
    # whether they are for a GET or POST request.
    #
    def before_GET(req)
      super
      @posted = vehicle(req).view if vehicle(req)
    end

    # ## `Admin::Vehicle#before_POST(req)`
    #
    # Set `@posted` to be a copy of the data posted in the request. Set 'dealership'
    # in posted data to the current dealership.
    #
    def before_POST(req)
      super
      posted['dealership'] = dealership(req)
    end

    # ## `Admin::Vehicle#menu_primary`
    #
    # Set up the primary menu view for Vehicle pages.
    #
    def menu_primary
      Lynr::View::Menu.new('Menu', @back_uri, nil, 'icon-back')
    end

    # ## `Admin::Vehicle#menu_secondary`
    #
    # Set up the secondary menu view for Vehicle pages.
    #
    def menu_secondary
      Lynr::View::Menu.new(
        'Vehicle Menu',
        "/admin/#{@dealership.slug}/#{@vehicle.slug}/menu",
        :menu_vehicle
      ) unless @vehicle.nil?
    end

    protected

    # ## `Admin::Vehicle#vehicle(req)`
    #
    # *Protected* Get vehicle object out of `req`.
    #
    def vehicle(req)
      return @vehicle unless @vehicle == false
      @vehicle = vehicle_dao.get(BSON::ObjectId.from_string(req['vehicle'])) unless req['vehicle'].nil?
    end

  end

end
