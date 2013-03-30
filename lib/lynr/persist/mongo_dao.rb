require 'mongo'
require './lib/lynr/config'

module Lynr; module Persist;

  class MongoDao

    attr_reader :config

    def initialize(collection='default')
      environment = ENV['whereami'] || 'development'
      defaults = {
        'mongo' => {
          'host'     => '127.0.0.1',
          'port'     => '27017',
          'database' => 'lynr'
        }
      }
      @config = Lynr::Config.new('database', environment, defaults)['mongo']
      @needs_auth = !@config['user'].nil? && !@config['pass'].nil?
      @collection_name = collection
    end

    # ## Manage the connection
    #
    def active?
      active = true
      begin
        self.db if @db.nil?
      rescue
        active = false
      end
      @authed && active && self.client.active?
    end

    def client
      @client = Mongo::MongoClient.new(@config['host'], @config['port']) if @client == nil
      @client
    end

    def collection
      @collection = db.collection(@collection_name) if @coll == nil
      @collection
    end

    def db
      if (@db.nil?)
        @db = client.db(@config['database'])
        self.authenticate if @needs_auth
      end
      @db
    end

    # ## Operate on the collection
    #
    def save(record, id=nil)
      result = record.dup
      success = false
      if (id)
        record.delete(:id)
        success = update(id, record)
      else
        id = create(record)
        success = !id.nil?
        result[:id] = id
      end

      success ? result : nil
    end

    def search(query, skip=nil, limit=nil)
      options = { }
      options[:skip] = skip if skip.is_a? Numeric
      options[:limit] = limit if limit.is_a? Numeric
      if (!limit.nil? && limit == 1)
        collection.find_one(query)
      else
        collection.find(query, options)
      end
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

    protected

    def authenticate
      if (@needs_auth)
        begin
          self.db.authenticate(@config['user'], @config['pass'])
          @authed = true
        rescue Mongo::AuthenticationError => mae
          @authed = false
        rescue Mongo::ConnectionFailure => mcf
          @authed = false
        end
      else
        @authed = true
      end
    end

  end

end; end;
