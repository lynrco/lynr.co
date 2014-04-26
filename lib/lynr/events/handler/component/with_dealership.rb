require './lib/lynr/persist/dealership_dao'

module Lynr

  class Events::Handler

    module WithDealership

      # ## `WithDealership#dealership(event)`
      #
      # Get a `Lynr::Model::Dealership` from the information provided in
      # `event`.
      #
      def dealership(event)
        dealership_dao.get(dealership_id(event))
      end

      # ## `WithDealership#dealership_dao`
      #
      # Get an instance of `Lynr::Persist::DealershipDao`
      #
      def dealership_dao
        @dealership_dao ||= Lynr::Persist::DealershipDao.new
      end

      # ## `WithDealership#dealership_id(event)`
      #
      # Extract the dealership_id from the information provided in `event`.
      #
      def dealership_id(event)
        event[:dealership_id]
      end

    end

  end

end
