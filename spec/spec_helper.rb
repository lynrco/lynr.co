require 'codeclimate-test-reporter'

require './lib/lynr/model/identity'
require './lib/lynr/persist/mongo_dao'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

# Set the environment so we run under the 'spec' settings
RSpec.configure do |c|
  c.add_setting :whereami, default: 'spec'
  c.add_setting :root, default: File.expand_path(File.dirname(__FILE__)).chomp('/spec')
  c.add_setting :env, default: [c.root, '.env'].join(File::SEPARATOR)
  if File.exists?(c.env) && File.readable?(c.env)
    File.readlines(c.env).each do |line|
      parts = line.chomp.split('=')
      ENV[parts[0]] = parts[1]
    end
  end
  if ENV.include?('whereami')
    c.whereami = ENV['whereami']
  else
    ENV['whereami'] = c.whereami
  end
  puts "ENVIRONMENT UNDER TEST = #{c.whereami}"
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
      next if coll_name.start_with?('system')
      db.collection(coll_name).remove()
      db.collection(coll_name).drop_indexes()
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
