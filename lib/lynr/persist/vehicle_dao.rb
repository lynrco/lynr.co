require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/vehicle'

module Lynr; module Persist;

  class VehicleDao

    SORT = ['created_at', Mongo::DESCENDING]

    def initialize
      @collection = 'vehicles'
      @dao = MongoDao.new('collection' => @collection)
      @index = false
      ensure_indices if @dao.active?
    end

    def get(id)
      record = @dao.read(id)
      record_to_vehicle(record)
    end

    def list(dealership, page=1, count=10)
      skip = (page - 1) * count
      options = { skip: skip, limit: count, sort: SORT }
      records = @dao.search({ 'dealership' => dealership.id, 'deleted_at' => nil }, options)
      records.map { |record| record_to_vehicle(record) }
    end

    def save(vehicle)
      record = @dao.save(vehicle_to_record(vehicle), vehicle.id)
      record_to_vehicle(record)
    end

    private

    def ensure_indices
      @dao.collection.ensure_index([['dealership', Mongo::ASCENDING], SORT])
      @indexed = true
    end

    def record_to_vehicle(record)
      # Mongo is going to give me a record with the _id property set, not id
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Vehicle.inflate(record)
    end

    def vehicle_to_record(vehicle)
      vehicle.view
    end

  end

end; end;
