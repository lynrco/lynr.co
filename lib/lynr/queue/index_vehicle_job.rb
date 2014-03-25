require './lib/lynr'
require './lib/lynr/elasticsearch'
require './lib/lynr/model/vehicle'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  # # `Lynr::Queue::IndexVehicleJob`
  #
  # Background `Job` to add a `Lynr::Model::Vehicle` instance as a
  # document to the elasticsearch cluster. The `Job` relies on
  # `Lynr::Elasticsearch` to provide a client for accessing the
  # elasticsearch cluster.
  #
  class IndexVehicleJob < Job

    attr_reader :vehicle

    # ## `IndexVehicleJob.new(vehicle)`
    #
    # Create a new background `Job` to add `vehicle` to the elasticsearch
    # indices.
    #
    def initialize(vehicle)
      @vehicle = vehicle
    end

    # ## `IndexVehicleJob#document`
    #
    # Get the document to be indexed. This is a modified version of
    # `Lynr::Model::Vehicle#view` which removes some of the larger text
    # fields which do not need to be indexed.
    #
    def document
      vehicle.view.tap { |view|
        view['dealership'] = view['dealership'].to_s
        view.delete('images')
        view['vin'].delete('raw')
      }
    end

    # ## `IndexVehicleJob#perform`
    #
    # Do the work of putting `@vehicle` into elasticsearch index.
    #
    def perform
      es = Lynr::Elasticsearch.new
      response = es.client.index({
                   index: 'vehicles',
                   type: vehicle.class.name,
                   id: vehicle.id.to_s,
                   body: document,
                 })
      Success
    rescue StandardError => e
      failure(e.message, :norequeue)
    end

    # ## `IndexVehicleJob#to_s`
    #
    # String representation of this `Job`
    #
    def to_s
      "#<#{self.class.name}:#{object_id} vehicle_id=#{@vehicle.id.to_s}>"
    end

  end

end; end;
