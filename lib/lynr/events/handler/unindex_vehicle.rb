require './lib/lynr'
require './lib/lynr/elasticsearch'
require './lib/lynr/events/handler'

module Lynr

  # # `Lynr::Events::Handler::UnindexVehicle`
  #
  # Take an event with a `:vehicle_id` and remove the identified vehicle
  # from the Elasticsearch index.
  #
  class Events::Handler::UnindexVehicle < Lynr::Events::Handler

    include Lynr::Events::Handler::WithVehicle

    # ## `Handler::UnindexVehicle#call(event)`
    #
    # Process `event` to remove `#vehicle(event)` from the Elasticsearch
    # 'vehicles' index.
    #
    def call(event)
      es = Lynr::Elasticsearch.new
      response = es.client.delete({
                   index: 'vehicles',
                   type: vehicle(event).class.name,
                   id: vehicle_id(event),
                 })
      require 'pry-debugger'
      binding.pry
      success
    rescue StandardError => e
      failure
    end

    def id() 'Handler::UnindexVehicle' end

  end

end
