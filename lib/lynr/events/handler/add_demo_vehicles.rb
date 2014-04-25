require 'yajl'

require './lib/lynr'
require './lib/lynr/events/handler'
require './lib/lynr/model/vehicle'

module Lynr

  # # `Lynr::Events::Handler::AddDemoVehicles`
  #
  # Event handler to add some example vehicles to a newly created demo
  # dealership.
  #
  class Events::Handler::AddDemoVehicles < Lynr::Events::Handler

    include Lynr::Events::Handler::WithDealership

    # ## `Handler::AddDemoVehicles#call(event)`
    #
    # Examine the dealership identified in `event`, if it is a demo
    # dealership then read example vehicles from `#filename` and save
    # them for the dealership.
    #
    def call(event)
      if dealership(event).subscription.demo?
        log.info("#{info(event)} msg=adding vehicles from `#{filename}`")
        vehicles(event).each do |vehicle|
          saved = vehicle_dao.save(vehicle.set({ 'dealership' => dealership(event) }))
          Lynr.producer('job').publish(Lynr::Queue::IndexVehicleJob.new(saved))
        end
      else
        log.info("#{info(event)} msg=live dealership, skipping")
      end
      success
    end

    # ## `Handler::AddDemoVehicles#filename`
    #
    # From where to read the example vehicle information.
    #
    def filename() 'config/data/demo_vehicles.json' end

    # ## `Handler::AddDemoVehicles#id`
    #
    # String identifier for this handler.
    #
    def id() "Handler::AddDemoVehicles" end

    # ## `Handler::AddDemoVehicles#info(event)`
    #
    # String used to identify this event and handler in log messages.
    #
    def info(event)
      "type=#{event[:type]} id=#{id} dealership=#{dealership(event).id}"
    end

    # ## `Handler::AddDemoVehicles#vehicles(event)`
    #
    # Get the vanilla vehicles from `#filename`. The vehicles from this
    # method have not yet had the dealership set on them.
    #
    def vehicles(event)
      data = Yajl::Parser.parse(File.open(filename))
      data.map { |datum| Lynr::Model::Vehicle.inflate(datum) }
    end

  end

end
