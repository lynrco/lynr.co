require './lib/lynr/cache/mongo_cache'

# # `Lynr::Cache`
#
# This module contains `Cache` implementations which all behave similarly.
# For information about the shared behavior see the shared specs at
# [spec/lib/lynr/cache_spec.rb](spec/lib/lynr/cache_spec.rb)
#
module Lynr::Cache

  def self.mongo
    return @mongo unless @mongo.nil?
    @mongo = Lynr::Cache::MongoCache.new
  end

end
