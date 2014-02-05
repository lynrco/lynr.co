require './lib/lynr/persist/mongo_dao'

module Lynr::Persist

  # # `Lynr::Persist::Dao`
  #
  # Generic DAO to save data of unknown type and be able to retrieve them by id.
  # Instances saved by this generic DAO must have `#id`, `#view` and `.inflate`
  # methods such that:
  #
  # * `#view` provides a `Hash` representation of the data to save including a
  #   'class' property with a namespaced class name.
  # * `#id` provides a unique id for the instance if it has been written to the
  #   database and nil otherwise.
  # * `.inflate` takes a `Hash` representation of the data and returns an instance
  #   of the appropriate type.
  #
  class Dao

    # ## `Dao.new`
    #
    # Create a new generics `Dao` instance for Creating, Reading, and Deleting
    # data.
    #
    def initialize
      @collection = 'generics'
      @dao = MongoDao.new('collection' => @collection)
    end

    # ## `Dao#create(instance)`
    #
    # Write `instance`'s data to the database and return a copy of `instance`
    # with its `id` set (assuming it did not have one).
    #
    def create(instance)
      record = @dao.save(instance.view, instance.id)
      translate(record)
    end

    # ## `Dao#include?(id)`
    #
    # Check if a record exists in the database with the given `id`.
    #
    def include?(id)
      @dao.collection.count({ query: { '_id' => id } }) > 0
    end

    # ## `Dao#read(id)`
    #
    # Retrieve an instance with `id` from the database and convert it into the
    # class specified by invoking the class property's `inflate` method.
    #
    def read(id)
      record = @dao.read(id)
      translate(record)
    end

    # ## `Dao#delete(id)`
    #
    # Remove an instance record with `id` from the database.
    #
    def delete(id)
      return false unless include?(id)
      @dao.delete(id)
    end

    private

    # ## `Dao#translate(record)`
    #
    # *Private* transform `record` into a class instance where the class name
    # was saved into the `record`.
    #
    def translate(record)
      return record if record.nil?
      record['id'] = record.delete('_id') if record.include?('_id')
      get_class(record['class']).inflate(record)
    end

    # ## Dao#get_class(class_name)`
    #
    # Translate `class_name` into a Class constant from which the `.inflate`
    # method can be invoked.
    #
    def get_class(class_name)
      class_name.split('::').inject(Kernel) do |scope, name|
        scope.const_get(name)
      end
    end

  end

end
