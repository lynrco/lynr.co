require 'bundler/setup'
require 'bunny'

require 'lynr'
require 'lynr/config'
require 'lynr/logging'
require 'lynr/queue'
require 'lynr/queue/job'
require 'lynr/queue/job_queue'

module Lynr

  class Worker

    include Lynr::Logging

    @app = false

    attr_reader :config

    def initialize(queue_name)
      @config = Lynr.config('app')
      @consumer = Lynr::Queue::JobQueue.new(queue_name, @config['amqp']['consumer'])
    end

    def call
      Signal.trap(:QUIT) { stop }
      Signal.trap(:TERM) { stop }

      begin
        @consumer.subscribe({ block: true })
      rescue Exception => e
        log.error(e)
        stop
      end
    end

    def stop
      @consumer.disconnect
      Process.exit(0)
    end

  end

end
