require 'yaml'
require 'mongo'

module Quicklist; module Persist;

  class MongoDao

    attr_reader :config

    def initialize(collection='default')
      environment = ENV['whereami'] || 'development'
      @config = YAML.load_file("config/database.#{environment}.yaml")['mongo']
      @client = Mongo::MongoClient.new(@config['host'], @config['port'])
      @db = @client.db(@config['database'])
      if (@config['user'] && @config['pass'])
        @db.authenticate(@config['user'], @config['pass'])
      end
      @coll = @db.collection(collection)
    end

    def get(id)
      read(id)
    end

    def save(obj)
      id = obj['id'] || obj[:id]
      result = obj.dup
      if (id)
        update(id, obj)
      else
        id = create(obj)
        result[:id] = id
      end
      result
    end

    def search(query, skip=nil, limit=nil)
      options = { }
      options[:skip] = skip if skip.is_a? Numeric
      options[:limit] = limit if limit.is_a? Numeric
      @coll.find(query, options)
    end

    protected

    # Returns the `_id` value for the new record
    def create(record)
      @coll.insert(record, { j: true })
    end

    # Returns the record
    def read(id)
      @coll.find_one({ _id: id })
    end

    # Returns `true` or the last error
    def update(id, obj)
      record = obj.reject { |k, v| k == 'id' || k == :id }
      @coll.update({ _id: id }, record, { j: true })
    end

    # Returns `true` or the last error
    def delete(id)
      @coll.remove({ _id: id }, { j: true })
    end

  end

end; end;
