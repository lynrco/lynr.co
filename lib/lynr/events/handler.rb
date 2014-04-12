require './lib/lynr'
require './lib/lynr/events'
require './lib/lynr/persist/dealership_dao'

module Lynr

  # # `Lynr::Events::Handler`
  #
  # Meant to be parent class for Event handlers. As such it implements
  # common functionality for them.
  #
  class Events::Handler

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

  end

end
