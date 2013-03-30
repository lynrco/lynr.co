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

    ##
    # ## `MongoDao#search`
    #
    # Generic method to look for records using any query. It is and exercise
    # for the user to make sure these aren't abused (e.g. they have indexes).
    #
    # *Note*: The return type of this method changes depending on the value
    # of the `:limit` option.
    #
    # ### Params
    #
    # * `query` Hash representing the type of record to search for
    # * `options` Hash options to pass along to the Mongo find query
    #   * `:limit` Numeric value restricting the number of results returned
    #   * `:skip` Numeric value telling how many matching records to skip
    #
    # ### Returns
    #
    # An Enumerable set of records matching `query` unless the `:limit` option
    # is passed and has a numeric value of one (1) in which case it returns a
    # single record.
    #
    def search(query, options={})
      limit = options[:limit] if options[:limit].is_a? Numeric
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
