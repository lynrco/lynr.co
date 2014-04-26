require './lib/lynr/persist/vehicle_dao'

module Lynr

  class Events::Handler

    module WithVehicle

      # ## `WithVehicle#vehicle(event)`
      #
      # Get a `Lynr::Model::Vehicle` from the information provided in
      # `event`.
      #
      def vehicle(event)
        vehicle_dao.get(vehicle_id(event))
      end

      # ## `WithVehicle#vehicle_dao`
      #
      # Get an instance of `Lynr::Persist::VehicleDao`
      #
      def vehicle_dao
        @vehicle_dao ||= Lynr::Persist::VehicleDao.new
      end

      # ## `WithVehicle#vehicle_id(event)`
      #
      # Extract the vehicle_id from the information provided in `event`.
      #
      def vehicle_id(event)
        event[:vehicle_id]
      end

    end

  end

end
