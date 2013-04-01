require './lib/lynr/model/identity'
require './lib/lynr/persist/mongo_dao'

# Set the environment so we run under the 'spec' settings
RSpec.configure do |c|
  ENV['whereami'] = 'spec'
end

# Define some helpers for interacting with Mongo
class MongoHelpers

  def self.dao(collection='dummy')
    Lynr::Persist::MongoDao.new({ 'collection' => collection })
  end

  def self.connected?
    MongoHelpers.dao.active?
  end

  def self.empty!
    db = dao.db
    db.collection_names.each do |coll_name|
      db.collection(coll_name).remove()
    end
  end

end

# Lower the cost of creating identity objects by lowering the work factor
# used by BCrypt
module Lynr; module Model;
  class Identity
    DEFAULT_COST = 5
  end
end; end;
