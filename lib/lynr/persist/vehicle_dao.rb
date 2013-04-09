require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/vehicle'

module Lynr; module Persist;

  class VehicleDao

    SORT = ['created_at', Mongo::DESCENDING]

    def initialize
      @dao = MongoDao.new('collection' => 'vehicles')
      @dao.collection.ensure_index([['dealership', Mongo::ASCENDING], SORT])
    end

    def get(id)
      record = @dao.read(id)
      # Mongo is going to give me a record with the _id property set, not id
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Vehicle.inflate(record)
    end

    def list(dealership, page=1, count=10)
      skip = (page - 1) * count
      options = { skip: skip, limit: count, sort: SORT }
      records = @dao.search({ 'dealership' => dealership.id }, options)
      records.map do |record|
        dealership_id = record.delete('dealership')
        Lynr::Model::Vehicle.inflate(record)
      end
    end

    def save(vehicle)
      record = @dao.save(vehicle.view, vehicle.id)
      Lynr::Model::Vehicle.inflate(record)
    end

  end

end; end;
