require 'mongo'
require './lib/lynr/config'

module Lynr; module Persist;

  class MongoDao

    attr_reader :config

    def initialize(collection='default')
      environment = ENV['whereami'] || 'development'
      @config = Lynr::Config.new('database', ENV['whereami'])['mongo']
      @collection_name = collection
    end

    # ## Manage the connection
    #
    def client
      @client = Mongo::MongoClient.new(@config['host'], @config['port']) if @client == nil
      @client
    end

    def db
      if (@db == nil)
        @db = client.db(@config['database'])
        if (@config['user'] && @config['pass'])
          @db.authenticate(@config['user'], @config['pass'])
        end
      end
      @db
    end

    def collection
      @collection = db.collection(@collection_name) if @coll == nil
      @collection
    end

    # ## Operate on the collection
    #
    def get(id)
      read(id)
    end

    def save(record, id=nil)
      result = record.dup
      success = false
      if (id)
        success = update(id, record)
      else
        id = create(record)
        success = !!id
        result[:id] = id
      end

      success ? result : nil
    end

    def search(query, skip=nil, limit=nil)
      options = { }
      options[:skip] = skip if skip.is_a? Numeric
      options[:limit] = limit if limit.is_a? Numeric
      collection.find(query, options)
    end

    # ## CRUD
    #
    # Returns the `_id` value for the new record
    def create(record)
      collection.insert(record, { j: true })
    end

    # Returns the record
    def read(id)
      collection.find_one({ _id: id })
    end

    # Returns `true` or the last error
    def update(id, obj)
      record = obj.reject { |k, v| k == 'id' || k == :id }
      collection.update({ _id: id }, record, { j: true })
    end

    # Returns `true` or the last error
    def delete(id)
      collection.remove({ _id: id }, { j: true })
    end

  end

end; end;
