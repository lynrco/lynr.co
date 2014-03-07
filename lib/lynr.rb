require './lib/lynr/cache'
require './lib/lynr/config'
require './lib/lynr/exceptions'
require './lib/lynr/queue/job_queue'
require './lib/lynr/metrics'

# # `Lynr`
#
# Base module to use as namespcae for the Lynr application.
#
module Lynr

  # `Lynr::VERSION` is the current version string for the Lynr application.
  VERSION = '0.0.1'

  # ## `Lynr.cache`
  #
  # Return an instance conforming to Lynr::Cache shared specs.
  #
  def self.cache
    Lynr::Cache.mongo
  end

  # ## `Lynr.config(type, defaults)`
  #
  # Helper method to retrieve a `Lynr::Config` instance based on `type` and
  # `Lynr.env`.
  #
  def self.config(type, defaults = {})
    Lynr::Config.new(type, Lynr.env, defaults)
  end

  # ## `Lynr.env(default)`
  #
  # Read `ENV['whereami']` to determine the environment in which Lynr application
  # is executing. Use `default` if `ENV['whereami']` is not defined.
  #
  def self.env(default = 'development')
    ENV['whereami'] || default
  end

  # ## `Lynr.metrics`
  #
  # Add a memoized universal accessor for a `Lynr::Metrics` instance.
  #
  def self.metrics
    return @metrics unless @metrics.nil?
    @metrics = Lynr::Metrics.new
  end

  # ## `Lynr.producer(name)`
  #
  # Helper method to retrive a `Lynr::Queue::JobQueue` based on `Lynr.env` and
  # `name`.
  #
  def self.producer(name)
    Lynr::Queue::JobQueue.new("#{Lynr.env}.#{name}", Lynr.config('app')['amqp']['producer'])
  end

  # ## `Lynr.root`
  #
  # Helper method to get the directory on the filesystem where the Lynr application
  # is deployed.
  #
  def self.root
    File.expand_path(File.dirname(__FILE__)).chomp('/lib')
  end

end
