require './lib/lynr/model/identity'
require './lib/lynr/persist/mongo_dao'

basedir = File.expand_path(File.dirname(__FILE__))
libdir = "#{basedir}/lib"
$LOAD_PATH.unshift(basedir) unless $LOAD_PATH.include?(basedir)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Set the environment so we run under the 'spec' settings
RSpec.configure do |c|
  c.add_setting :whereami
  c.whereami = ENV['whereami'] || 'spec'
  ENV['whereami'] = c.whereami
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
      db.collection(coll_name).remove() if !coll_name.start_with?('system')
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
