require './lib/lynr'
require './lib/lynr/elasticsearch'
require './lib/lynr/model/vehicle'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  # # `Lynr::Queue::VehicleIndexJob`
  #
  # Background `Job` to add a `Lynr::Model::Vehicle` instance as a
  # document to the elasticsearch cluster. The `Job` relies on
  # `Lynr::Elasticsearch` to provide a client for accessing the
  # elasticsearch cluster.
  #
  class IndexVehicleJob < Job

    attr_reader :vehicle

    # ## `VehicleIndexJob.new(vehicle)`
    #
    # Create a new background `Job` to add `vehicle` to the elasticsearch
    # indices.
    #
    def initialize(vehicle)
      @vehicle = vehicle
    end

    # ## `VehicleIndexJob#perform`
    #
    # Do the work of putting `@vehicle` into elasticsearch index.
    #
    def perform
      es = Lynr::Elasticsearch.new
      response = es.client.index({
                   index: 'vehicles',
                   type: vehicle.class.name,
                   id: vehicle.id.to_s,
                   body: vehicle.view,
                 })
      Success
    rescue StandardError => e
      failure(e.message, :norequeue)
    end

    # ## `VehicleIndexJob#to_s`
    #
    # String representation of this `Job`
    #
    def to_s
      "#<#{self.class.name}:#{object_id} vehicle_id=#{@vehicle.id.to_s}>"
    end

  end

end; end;
