require './lib/lynr/exceptions'

module Lynr::Persist

  # # `Lynr::Persist::MongoUniqueError`
  #
  # Used to create a nicer representation of a `Mongo::OperationFailure`
  # error which is raised because of a violation of an index with a unique
  # constraint.
  #
  class MongoUniqueError < Lynr::DataError

    # ## `MongoUniqueError.new(mongo_error)`
    #
    # The constructor takes an Error and attempts to parse it's message
    # property for a field name and a value. The successful parsing of `field`
    # requires the index have a name based on the field name.
    #
    def initialize(mongo_error)
      message = mongo_error.message
      data = message.match(/\$(?<field>\w+)_\d[^"]*"(?<value>.+)"/)
      field = data['field']
      value = data['value']
      super(data['field'], data['value'], message, mongo_error)
    end

  end

end
