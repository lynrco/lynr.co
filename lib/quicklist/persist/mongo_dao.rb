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

    protected

    def create(record)
      @coll.insert(record, { j: true })
    end

    def update(id, obj)
      record = obj.reject { |k, v| k == 'id' || k == :id }
      @coll.update({ _id: id }, record, { j: true })
    end

  end

end; end;
