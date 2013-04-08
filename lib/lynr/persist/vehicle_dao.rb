require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/vehicle'

module Lynr; module Persist;

  class VehicleDao

    def initialize
      @dao = MongoDao.new('collection' => 'vehicles')
      #@dao.collection.ensure_index([['identity.email', Mongo::ASCENDING]], { unique: true })
    end

    def get(id)
      record = @dao.read(id)
      # Mongo is going to give me a record with the _id property set, not id
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Vehicle.inflate(record)
    end

    def save(vehicle)
      record = @dao.save(vehicle.view, vehicle.id)
      Lynr::Model::Vehicle.inflate(record)
    end

  end

end; end;
