require './lib/lynr/persist/mongo_dao'

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
      next if coll_name.start_with?('system')
      db.collection(coll_name).remove()
      db.collection(coll_name).drop_indexes()
    end
  end

end
