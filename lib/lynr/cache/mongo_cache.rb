require './lib/lynr/cache'
require './lib/lynr/persist/mongo_dao'

module Lynr::Cache

  # # `Lynr::Cache::MongoCache`
  #
  # MongoDB based implementation of the `Lynr::Cache` specification. For more
  # information on the shared `Lynr::Cache` specification please see
  # [spec/lib/lynr/cache_spec.rb](spec/lib/lynr/cache_spec.rb). MongoDB interactions
  # are handled by the lower-level `Lynr::Persist::MongoDao` class.
  #
  class MongoCache

    # ## `Lynr::Cache::MongoCache.new(config)`
    #
    # Create instance of `Lynr::Cache` compatible cache backed by MongoDB. `config`,
    # if given, overrides the Mongo connection information provided in the configuration
    # file.
    #
    def initialize(config={})
      cfg = (config || {}).merge({ 'collection' => 'lynr_cache' })
      @dao = Lynr::Persist::MongoDao.new(cfg)
    end

    # ## `MongoCache#available?`
    #
    # Whether or not the backing service for this cache implementation is accessible. In
    # practice, checks that MongoDB from `config` or the configuration file can be reached.
    #
    def available?
      @dao.active?
    end

    # ## `MongoCache#clear`
    #
    # Unsets all cache keys.
    #
    def clear
      @dao.collection.remove
    end

    # ## `MongoCache#include?(key)`
    #
    # Checks if `key` been set.
    #
    def include?(key)
      @dao.count(selector(key)) > 0
    end

    # ## `MongoCache#read(key, default)`
    #
    # *Aliased as `#get`*.
    #
    # Retrieves the cache value associated with `key` if one exists. If no cached value
    # exists (i.e. `#include(key)` is false) return `default` if given, `nil` otherwise.
    #
    def read(key, default=nil)
      document = @dao.collection.find_one(selector(key))
      if !document.nil?
        document['v']
      else
        default
      end
    end

    # ## `MongoCache#remove(key)`
    #
    # *Aliased as `#del`*.
    #
    # Unset `key`.
    #
    def remove(key)
      @dao.collection.remove(selector(key))
    end

    # ## `MongoCache#write(key, value)`
    #
    # *Aliased as `#set`*.
    #
    # Set the cache value for `key` to be `value`. Overwrites the stored value if one exists.
    #
    def write(key, value)
      @dao.collection.save({ '_id' => key, 'v' => value })
    end

    alias :del :remove
    alias :get :read
    alias :set :write

    private

    def selector(key)
      { '_id' => key }
    end

  end

end
