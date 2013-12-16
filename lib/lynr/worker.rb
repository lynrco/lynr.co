require 'bundler/setup'
require 'bunny'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/logging'
require './lib/lynr/queue'
require './lib/lynr/queue/job'
require './lib/lynr/queue/job_queue'

require './lib/lynr/queue/email_job'
require './lib/lynr/queue/geocode_job/google'
require './lib/lynr/queue/post_craigslist_job'
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
      [:QUIT, :TERM, :INT].each do |sig|
        Signal.trap(sig) { stop }
      end

      queue_info = "pid=#{Process.pid} queue=#{@consumer.name}"

      log.info("#{queue_info} state=started")
      @consumer.subscribe({ block: true }) do |job|
        result = job.perform
        log.info("#{queue_info} #{job.info} job.result=#{result.info}")
        if result.success?
          @consumer.ack(job.delivery_info.delivery_tag)
        else
          @consumer.nack(job.delivery_info.delivery_tag, result.requeue?)
        end
      end
    rescue Bunny::ConnectionClosedError, Bunny::NetworkFailure => be
      log.warn(be.message)
      log.debug(be)
      call
    rescue SystemExit => sysexit
      stop unless sysexit.success?
    rescue Exception => e
      log.error(e)
      stop
    end

    def stop
      log.info("Worker for queue '#{@consumer.name}' exiting on pid: #{Process.pid}")
      @consumer.disconnect
      Process.exit(0)
    end

  end

end
