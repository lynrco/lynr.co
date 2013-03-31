require './lib/lynr/persist/mongo_dao'

# Set the environment so we run under the 'spec' settings
RSpec.configure do |c|
  ENV['whereami'] = 'spec'
end

class MongoHelpers
  def self.dao
    Lynr::Persist::MongoDao.new({ 'collection' => 'dummy' })
  end
  def self.connected?
    MongoHelpers.dao.active?
  end
end

# Lower the cost of creating identity objects by lowering the work factor
# used by BCrypt
module Lynr; module Model;
  class Identity
    DEFAULT_COST = 5
  end
end; end;
