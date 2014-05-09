require 'mongo'

require './lib/bson/dbref'

require './lib/lynr'
require './lib/lynr/config'

module Lynr; module Persist;

  # # Lynr::Persist::MongoDao
  #
  # Interface for use within other Data Access Objects to handle the interaction
  # with a MongoDB server or replica set. This allows the creation of an
  # abstract API so the nitty gritty of the [mongo-ruby-driver][mrd]
  # implementation can be hidden.
  #
  # [mrd]: https://github.com/mongodb/mongo-ruby-driver
  #
  class MongoDao

    attr_reader :config

    # ## `Lynr::Persist::MongoDao::MongoDefaults`
    #
    # Hash containing the default connection properties to use when no
    # configration is provided to the constructor.
    #
    MongoDefaults = { 'host' => 'localhost', 'port' => '27017', 'database' => 'lynrco' }
    MongoCollectionOptions = { read: :secondary }

    # ## `Lynr::Persist::MongoDao.new`
    #
    # Create a new instance that is connected to the specified collection. Sets
    # up the configuration based on the environment.
    #
    # ### Params
    #
    # * `config` map of configuration options
    #
    # ### Config
    #
    # * 'host' ip or hostname to reach MongoDB instance
    # * 'port' number to access MongoDB on 'host'
    # * 'database' to which MongoDao will connect
    # * 'collection' name to interact with to on the MongoDB instance
    #
    def initialize(config=nil)
      defaults = config || MongoDefaults
      @config = Lynr::Config.new('database', Lynr.env, { 'mongo' => defaults }).mongo
      @collection_name = @config['collection']
      @db, @client, @collection = nil
    end

    # ## Manage the connection
    #
    def active?
      active = true
      begin
        self.client.connect
        self.db if @db.nil?
      rescue
        active = false
      end
      active && self.client.connected? && self.client.active?
    end

    def client
      return @client unless @client.nil?
      @client = Mongo::MongoClient.from_uri(uri)
    end

    def collection
      return @collection unless @collection.nil?
      @collection = db.collection(@collection_name, MongoCollectionOptions)
    end

    def credentials
      "#{@config['user']}:#{@config['pass']}" if credentials?
    end

    def credentials?
      !@config['user'].nil? && !@config['pass'].nil?
    end

    def db
      return @db unless @db.nil?
      @db = client.db
    end

    # ## Operate on the collection
    #
    def count(query={})
      collection.count({ query: query })
    end

    def save(record, id=nil)
      result = record.dup
      success = false
      if (id)
        record.delete('id')
        success = update(id, record)
      else
        id = create(record)
        success = !id.nil?
      end
      result['_id'] = id

      success ? result : nil
    end

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

    # ## `MongoDao#uri`
    #
    # Construct a mongodb connection string based on the configuratino. First
    # tries to fetch the URI from the configuration created during initialize
    # if there is no URI available in the config then construct a URI from the
    # user, pass, host, port values in config.
    #
    # ### Returns
    #
    # A URI string of the form 'mongodb://<user>:<pass>@host:port[,host:port[,host:port]...]/database'
    #
    def uri
      if @config.include?('uri')
        @config['uri']
      elsif credentials?
        "mongodb://#{credentials}@#{@config['host']}:#{@config['port']}/#{@config['database']}"
      else
        "mongodb://#{@config['host']}:#{@config['port']}/#{@config['database']}"
      end
    end

    # ## CRUD
    #
    # Returns the `_id` value for the new record
    def create(record)
      now = Time.now
      record['created_at'] ||= now
      record['updated_at'] ||= now
      collection.insert(record)
    end

    # Returns the record
    def read(id)
      collection.find_one({ _id: id })
    end

    # Returns `true` or the last error
    def update(id, obj)
      record = obj.reject { |k, v| k == 'id' || k == :id }
      record['updated_at'] ||= Time.now
      collection.update({ _id: id }, record)
    end

    # Returns `true` or the last error
    def delete(id)
      collection.remove({ _id: id })
    end

  end

end; end;
