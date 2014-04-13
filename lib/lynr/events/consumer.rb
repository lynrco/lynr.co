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
      JSON.parse(payload, symbolize_names: true)
    rescue JSON::JSONError => e
      log.warn("type=parse.error payload=#{paylaod}")
    end

    # ## `Events::Consumer#handlers_for(event)`
    #
    # Retrieves the handlers for the `:type` in a given `event`. This is
    # used to retrieve the current set of handlers used to process a
    # received `event`.
    #
    def handlers_for(event)
      handlers = @semaphore.synchronize {
        @backend.fetch(event[:type], [])
      }
      skippable = event.fetch(:_skippable, [])
      handlers.reject { |handler| skippable.include?(handler.id) }
    end

    # ## `Events::Consumer#process(delivery_info, metadata, payload)`
    #
    # Defines what to do when a messages is received from `#consumer`.
    #
    def process(delivery_info, metadata, payload)
      event = deserialize(delivery_info, metadata, payload)
      event[:_attempts] ||= 0
      handlers = handlers_for(event)
      results = handlers.map { |handler| handler.call(event) }
      successes = results.select { |result| result.is_a?(Lynr::Events::Handler::Success) }
      log.debug("type=processed payload=#{event.to_json}")
      if successes.length != handlers.length && event[:_attempts] < 3
        event[:_skippable] = successes
        event[:_attempts] += 1
        Lynr::Events.emit(event)
      end
      consumer.ack(delivery_info.delivery_tag)
    end

  end

end
