require 'codeclimate-test-reporter'

require './spec/support/config_helper'
require './spec/support/model_helper'
require './spec/support/mongo_helper'
require './spec/support/route_helper'

require './lib/lynr/model/identity'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

# Set the environment so we run under the 'spec' settings
RSpec.configure do |c|
  c.add_setting :whereami, default: 'spec'
  c.add_setting :root, default: File.expand_path(File.dirname(__FILE__)).chomp('/spec')
  c.add_setting :env, default: [c.root, '.env'].join(File::SEPARATOR)

  $VERBOSE = nil

  if File.exists?(c.env) && File.readable?(c.env)
    File.readlines(c.env).each do |line|
      parts = line.chomp.split('=')
      ENV[parts[0]] = parts[1]
    end
  end

  c.after(:each) do
    MongoHelpers.empty! if MongoHelpers.dao.active?
  end

  Log4r::Logger.global.level = 6

  if ENV.include?('whereami')
    c.whereami = ENV['whereami']
  else
    ENV['whereami'] = c.whereami
  end
  puts "ENVIRONMENT UNDER TEST = #{c.whereami}"
end

# Lower the cost of creating identity objects by lowering the work factor
# used by BCrypt
module Lynr; module Model;
  class Identity
    DEFAULT_COST = 5
  end
end; end;
