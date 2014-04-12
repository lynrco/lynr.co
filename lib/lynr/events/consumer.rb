require 'yajl/json_gem'

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
      @backend = {}
      @semaphore = Mutex.new
    end

    # ## `Events::Consumer#add(type, handler)`
    #
    # Add an event handler to the `Consumer` instance. `handler` is used
    # to process events of `type` when they are received from `#consumer`.
    #
    def add(type, handler)
      if !handler.respond_to?(:call)
        raise ArgumentError.new("Lynr::Events handler must respond_to?(:call)")
      end
      @semaphore.synchronize {
        subscribers = @backend.fetch(type, [])
        @backend.store(type, subscribers.dup << handler)
      }
      self
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

    # ## `Events::Consumer#handlers_for(type)`
    #
    # Retrieves the handlers for the given `type` of event. This is
    # used to retrieve the current set of handlers used to process a
    # received event.
    #
    def handlers_for(type)
      @semaphore.synchronize {
        @backend.fetch(type, [])
      }
    end

    # ## `Events::Consumer#process(delivery_info, metadata, payload)`
    #
    # Defines what to do when a messages is received from `#consumer`.
    #
    def process(delivery_info, metadata, payload)
      event = deserialize(delivery_info, metadata, payload)
      handlers = handlers_for(event['type'])
      results = handlers.map do |handler|
        handler.call(event)
        log.info("type=processed.handler handler=#{handler.id}")
      end
      log.info("type=processed payload=#{event.to_json}")
    end

  end

end
