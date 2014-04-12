require './lib/lynr'
require './lib/lynr/events'
require './lib/lynr/queue'
require './lib/lynr/worker'

module Lynr

  # # `Lynr::Events::Consumer`
  #
  # The `Lynr::Worker` which is used to process events data.
  #
  class Events::Consumer < Lynr::Worker

    # ## `Events::Consumer.new`
    #
    # Create a new `Lynr::Worker` instance to process messages from the
    # 'events' queue.
    #
    def initialize
      super("#{Lynr.env}.events")
    end

    # ## `Events::Consumer#consumer`
    #
    # Define the `Lynr::Queue` instance from which messages will be
    # consumed.
    #
    def consumer
      @consumer ||= Lynr::Queue.new(queue_name, Lynr.config('app').amqp.producer, Events::QUEUE_OPTS)
    end

    # ## `Events::Consumer#deserialize(delivery_info, metadata, payload)`
    #
    # Translate `delivery_info`, `metadata` and `payload` into an event
    # which be consumed be processed.
    #
    def deserialize(delivery_info, metadata, payload)
      JSON.parse(payload)
    rescue JSON::JSONError => e
      log.warn("type=parse.error payload=#{paylaod}")
    end

    # ## `Events::Consumer#process(delivery_info, metadata, payload)`
    #
    # Defines what to do when a messages is received from `#consumer`.
    #
    def process(delivery_info, metadata, payload)
      event = deserialize(delivery_info, metadata, payload)
      log.info("type=processed payload=#{event.to_json}")
    end

  end

end
