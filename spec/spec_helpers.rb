require './lib/lynr/persist/mongo_dao'

class MongoHelpers
  def self.dao
    ENV['whereami'] = 'spec'
    Lynr::Persist::MongoDao.new({ 'collection' => 'dummy' })
  end
  def self.connected?
    MongoHelpers.dao.active?
  end
end

