require './lib/lynr'
require './lib/lynr/queue'

module Lynr

  # # `Lynr::Events`
  #
  # Used to emit or create events which will be processed in the
  # background.
  #
  class Events

    autoload :Consumer, './lib/lynr/events/consumer'

    PUBLISH_OPTS = { content_type: 'application/json' }
    QUEUE_OPTS = { publish: PUBLISH_OPTS }

    # ## `Events#emit(event)`
    #
    # Publish `event` to the message broker to be handled later. Returns
    # `self` for chaining. An 'event' must have a `:type` property and
    # must not have `:_skippable` or `:_attempts` properties, anything
    # else is fair game.
    #
    def emit(event={})
      producer.publish(event.to_json)
      self
    end

    # ## `Events#producer`
    #
    # Defines the `Lynr::Queue` instance to which events will be
    # `emit`ed.
    #
    def producer
      @producer ||= Lynr::Queue.new("#{Lynr.env}.events", Lynr.config('app').amqp.producer, Events::QUEUE_OPTS)
    end

    # ## `Events.emit(event)`
    #
    # Create a new `Lynr::Events` instance and delegate to its `#emit`
    # method.
    #
    def self.emit(event={})
      Events.new.emit(event)
    end

  end

end
