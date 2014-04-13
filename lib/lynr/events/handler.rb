require './lib/lynr'
require './lib/lynr/events'
require './lib/lynr/logging'
require './lib/lynr/persist/dealership_dao'

module Lynr

  # # `Lynr::Events::Handler`
  #
  # Meant to be parent class for Event handlers. As such it implements
  # common functionality for them.
  #
  class Events::Handler

    include Lynr::Logging

    attr_reader :data

    # ## `Events::Handler.new(data)`
    #
    # Store `data` to be accessed later. Default constructor for child
    # classes so the same behavior doesn't need to be repeated.
    #
    def initialize(data={})
      @data = data
    end

    # ## `Events::Handler#dealership_dao`
    #
    # Get an instance of `Lynr::Persist::DealershipDao`
    #
    def dealership_dao
      @dealership_dao ||= Lynr::Persist::DealershipDao.new
    end

    # ## `Events::Handler#failure`
    #
    # Create an `Events::Handler::Failure` instance for this handler's
    # `#id`.
    #
    def failure() Failure.new(id) end

    # ## `Events::Handler#id`
    #
    # Unique id of this handler. Must be thread safe and unique to the
    # configured handler. Meaning if the behavior varies by the data
    # provided to the constructor the id needs to vary by the same data.
    #
    def id
      raise NoMethodError.new("`Lynr::Events::Handler#id` must be defined in subclass")
    end

    # ## `Events::Handler#success`
    #
    # Create an `Events::Handler::Success` instance for this handler's
    # `#id`.
    #
    def success() Success.new(id) end

    # ## `Events::Handler.from(config)`
    #
    # Takes a `config` `Hash` containing a 'type' key. 'type' is used to
    # determine the class by incrementally calling `.const_get` on the
    # scope. Once the type has been resolved `config` is passed to the
    # constructor.
    #
    def self.from(config)
      class_name = config.delete('type')
      type = class_name.split('::').inject(Kernel) do |scope, name|
        scope.const_get(name)
      end
      type.new(config)
    end

    # # `Lynr::Events::Handler::Success`
    #
    # Represents successful processing by a `Handler`
    #
    class Success < String; end

    # # `Lynr::Events::Handler::Failure`
    #
    # Represents unsuccessful processing by a `Handler`
    #
    class Failure < String; end

  end

end
