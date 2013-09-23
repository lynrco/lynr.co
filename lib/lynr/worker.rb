require 'bundler/setup'
require 'bunny'

require 'lynr'
require 'lynr/config'
require 'lynr/logging'
require 'lynr/queue'
require 'lynr/queue/job'
require 'lynr/queue/job_queue'

require 'lynr/queue/email_job'
require 'lynr/queue/stripe_update_job'

module Lynr

  class Worker

    include Lynr::Logging

    attr_reader :config

    def initialize(queue_name)
      @config = Lynr.config('app')
      @consumer = Lynr::Queue::JobQueue.new(queue_name, @config['amqp']['consumer'])
    end

    def call
      Signal.trap(:QUIT) { stop }
      Signal.trap(:TERM) { stop }

      @consumer.subscribe({ block: true }) do |job, result|
        log.info "Processed #{delivery_info.delivery_tag} -- #{result.to_s}" if job.delivered?
      end
    rescue Bunny::NetworkFailure => bnf
      log.warn(bnf)
      call
    rescue Exception => e
      log.error(e)
      stop
    end

    def stop
      @consumer.disconnect
      Process.exit(0)
    end

  end

end
