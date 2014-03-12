module Lynr

  # # `Lynr::Cache`
  #
  # This module contains `Cache` implementations which all behave similarly.
  # For information about the shared behavior see the shared specs at
  # [spec/lib/lynr/cache_spec.rb](spec/lib/lynr/cache_spec.rb)
  #
  module Cache

    # ## `Lynr::Cache.mongo`
    #
    # Provides an instance of `Lynr::Cache::MongoCache` with the default configuration.
    #
    def self.mongo
      return @mongo unless @mongo.nil?
      require './lib/lynr/cache/mongo_cache'
      @mongo = Lynr::Cache::MongoCache.new
    end

  end

end
