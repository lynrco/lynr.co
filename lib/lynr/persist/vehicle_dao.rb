require './lib/lynr/persist/mongo_dao'
require './lib/lynr/model/vehicle'

module Lynr; module Persist;

  # # `Lynr::Persist::VehicleDao`
  #
  # Data Access Object specialized to interact with `Lynr::Model::Vehicle`
  # instances.
  #
  class VehicleDao

    SORT = ['created_at', Mongo::DESCENDING]

    # ## `VehicleDao.new`
    #
    # Establish a connection to backing database and create indices if they
    # don't exist.
    #
    def initialize
      @collection = 'vehicles'
      @dao = MongoDao.new('collection' => @collection)
      @index = false
      ensure_indices if @dao.active?
    end

    # ## `VehicleDao#get(id)`
    #
    # Retrieve the `Vehicle` identified by `id`.
    #
    def get(id)
      record = @dao.read(id)
      record_to_vehicle(record)
    end

    # ## `VehicleDao#list(dealership, page, count)
    #
    # Retrieve a list of `Vehicle` instances associated with `dealership`.
    #
    def list(dealership, page=1, count=10)
      skip = (page - 1) * count
      options = { skip: skip, limit: count, sort: SORT }
      records = @dao.search({ 'dealership' => dealership.id, 'deleted_at' => nil }, options)
      records.map { |record| record_to_vehicle(record) }
    end

    # ## `VehicleDao#save(vehicle)`
    #
    # Create a new record for `vehicle` or update the record associated with it.
    #
    def save(vehicle)
      record = @dao.save(vehicle_to_record(vehicle), vehicle.id)
      record_to_vehicle(record)
    end

    private

    # ## `VehicleDao#ensure_indices`
    #
    # Create appropriate indexes on the database structure backing this 'table'.
    #
    def ensure_indices
      @dao.collection.ensure_index([['dealership', Mongo::ASCENDING], SORT])
      @indexed = true
    end

    # ## `VehicleDao#record_to_vehicle(record)`
    #
    # Take a record `Hash` provided by the database and turn it into a `Vehicle`
    # instance.
    #
    def record_to_vehicle(record)
      # Mongo is going to give me a record with the _id property set, not id
      record['id'] = record.delete('_id') if !record.nil?
      Lynr::Model::Vehicle.inflate(record)
    end

    # ## `VehicleDao#vehicle_to_record(vehicle)`
    #
    # Take a `Vehicle` instance and turn it into a `Hash` record for the database.
    #
    def vehicle_to_record(vehicle)
      vehicle.view
    end

  end

end; end;
