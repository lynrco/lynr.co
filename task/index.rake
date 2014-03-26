namespace :lynr do

  namespace :elasticsearch do

    require 'bson'
    require './lib/lynr'
    require './lib/lynr/persist/dealership_dao'
    require './lib/lynr/persist/vehicle_dao'
    require './lib/lynr/queue/index_vehicle_job'

    desc 'Add each vehicle owned by `dealership` (slug or id) to elasticsearch'
    task :index, :dealership do |t, args|

      index_vehicles_for(args[:dealership])

    end

    desc 'Add each vehicle for each dealership to elasticsearch'
    task :indexall do

      # NOTE: Requires knowledge of `Lynr::Persist::DealershipDao` internals
      collection = dealership_dao.instance_variable_get(:@dao)
      collection.search({}, fields: ['_id']).each do |record|
        index_vehicles_for(record['_id'])
      end

    end

    def dealership_dao
      return @dealership_dao unless @dealership_dao.nil?
      @dealership_dao = Lynr::Persist::DealershipDao.new
    end

    def index_vehicles_for(dealership_id)
      dealership =
        if dealership_id.is_a?(BSON::ObjectId)
          dealership_dao.get(dealership_id)
        elsif BSON::ObjectId.legal?(dealership_id)
          dealership_dao.get(BSON::ObjectId.from_string(dealership_id))
        else
          dealership_dao.get_by_slug(dealership_id)
        end

      # NOTE: Requires knowledge of `Lynr::Persist::VehicleDao` internals
      collection = vehicle_dao.instance_variable_get(:@dao)

      collection.search({ dealership: dealership.id }, fields: ['_id']).each do |record|
        vehicle = vehicle_dao.get(record['_id'])
        Lynr.producer('job').publish(Lynr::Queue::IndexVehicleJob.new(vehicle))
      end
    end

    def vehicle_dao
      return @vehicle_dao unless @vehicle_dao.nil?
      @vehicle_dao = Lynr::Persist::VehicleDao.new
    end

  end

end
