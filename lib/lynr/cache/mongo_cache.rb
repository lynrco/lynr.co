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

    def initialize(config={})
      cfg = (config || {}).merge({ 'collection' => 'lynr_cache' })
      @dao = Lynr::Persist::MongoDao.new(cfg)
    end

    def available?
      @dao.active?
    end

    def clear
      @dao.collection.remove
    end

    def include?(key)
      @dao.collection.count({ '_id' => key }) > 0
    end

    def read(key, default=nil)
      document = @dao.collection.find_one(selector(key))
      if !document.nil?
        document['v']
      else
        default
      end
    end

    def remove
    end
    
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
