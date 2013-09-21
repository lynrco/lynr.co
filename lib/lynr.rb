require 'lynr/queue/job_queue'

module Lynr

  API_ROOT = '/api'
  API_VERSION = 'v1'
  API_BASE = "#{API_ROOT}/#{API_VERSION}"

  VERSION = '0.0.1'

  def self.config(type, defaults = {})
    Lynr::Config.new(type, Lynr.env, defaults)
  end

  def self.env(default = 'development')
    ENV['whereami'] || default
  end

  def self.producer(name)
    Lynr::Queue::JobQueue.new("#{Lynr.env}.#{name}", Lynr.config('app')['amqp']['producer'])
  end

  def self.root
    __DIR__.chomp('/lib')
  end

end
