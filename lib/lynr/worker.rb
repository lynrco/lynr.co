require 'bundler/setup'
require 'bunny'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/logging'
require './lib/lynr/queue'
require './lib/lynr/queue/job'
require './lib/lynr/queue/job_queue'

require './lib/lynr/queue/email_job'
require './lib/lynr/queue/stripe_update_job'

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

      @consumer.subscribe({ block: true }) do |job|
        result = job.perform
        log.info "Processed #{job.delivery_info.delivery_tag} -- #{result.to_s}" if job.delivered?
        if result.success?
          @consumer.ack(job.delivery_info.delivery_tag)
        else
          @consumer.nack(job.delivery_info.delivery_tag)
        end
      end
    rescue Bunny::ConnectionClosedError => bcce
      log.warn(bcce.message)
      log.debug(bcce)
      stop
    rescue Bunny::NetworkFailure => bnf
      log.warn(bnf.message)
      log.debug(bnf)
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
