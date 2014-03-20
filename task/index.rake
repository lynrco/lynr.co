namespace :lynr do

  namespace :elasticsearch do

    desc 'Add each vehicle owned by `dealership` (slug or id) to elasticsearch'
    task :index, :dealership do |t, args|

      require 'bson'
      require './lib/lynr'
      require './lib/lynr/persist/dealership_dao'
      require './lib/lynr/persist/vehicle_dao'
      require './lib/lynr/queue/index_vehicle_job'

      dealership_dao = Lynr::Persist::DealershipDao.new
      vehicle_dao = Lynr::Persist::VehicleDao.new

      dealership =
        if BSON::ObjectId.legal?(args[:dealership])
          dealership_dao.get(BSON::ObjectId.from_string(args[:dealership]))
        else
          dealership_dao.get_by_slug(args[:dealership])
        end

      # NOTE: `VehicleDao#list` on returns 10 results
      vehicles = vehicle_dao.list(dealership)

      vehicles.each do |vehicle|
        Lynr.producer('job').publish(Lynr::Queue::IndexVehicleJob.new(vehicle))
      end

    end

  end

end
