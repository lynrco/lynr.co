require 'codeclimate-test-reporter'
require 'stripe_mock'

require './spec/matchers/have_element'
require './spec/support/config_helper'
require './spec/support/demo_helper'
require './spec/support/model_helper'
require './spec/support/mongo_helper'
require './spec/support/route_helper'
require './spec/support/token_helper'

require './lib/lynr/model/identity'

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

  c.before(:suite) do
    StripeMock.start
  end
  c.after(:suite) do
    StripeMock.stop
  end

  c.before(:each) do
    Lynr::Queue.any_instance.stub(:publish) do |job, opts|
      self
    end
    Lynr::Queue::JobQueue.any_instance.stub(:publish) do |job, opts|
      self
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
    DEFAULT_COST = 1
  end
end; end;
