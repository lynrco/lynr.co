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
require './lib/lynr/queue/markdown_email_job'
require './lib/lynr/queue/post_craigslist_job'
require './lib/lynr/queue/stripe_update_job'

module Lynr

  # # `Lynr::Worker`
  #
  # Workhorse class for job queue processing. `Worker` creates a `JobQueue` and then
  # subscribes to the channel waiting for message deliveries. Messges are processed
  # one at a time by invoking the `Job`'s `#perform` method. `Worker` traps `QUIT`,
  # `TERM`, and `INT` signals and invokes `Worker#stop` upon receipt of one of these
  # signals to gracefully stop the `JobQueue` consumers and tell the `Process` to exit.
  # The `#stop` method is also invoked when `Job#perform` or `JobQueue#subscribe` raise
  # exceptions. Worker is a process aware wrapper around `Lynr::Queue::JobQueue`.
  #
  class Worker

    include Lynr::Logging

    attr_reader :config

    # ## `Lynr::Worker.new(queue_name)`
    #
    # Create a new `Worker` with `queue_name` as the name of the `JobQueue` used
    # to process the `Worker`'s messages.
    #
    def initialize(queue_name)
      @config = Lynr.config('app')
      @consumer = Lynr::Queue::JobQueue.new(queue_name, @config['amqp']['consumer'])
    end

    # ## `Lynr::Worker#call`
    #
    # Set up the signal traps and message subscription. When backing `JobQueue`
    # receives a message and passes it along `Worker` invokes `#process` and
    # sends the received `Job`.
    #
    def call
      [:QUIT, :TERM, :INT].each do |sig|
        Signal.trap(sig) { stop }
      end

      log.info("#{queue_info} state=started")
      @consumer.subscribe({ block: true }) { |job| process(job) }
    rescue SystemExit => sysexit
      stop unless sysexit.success?
    rescue Exception => e
      log.error("#{queue_info} state=error message=#{e.message} type=#{e.class.name}")
      stop
    end

    # ## `Lynr::Worker#process(job)`
    #
    # Perform the `job` provided by the `@consumer` while subscribed. This
    # method is the one that makes the action happen. If `perform` returns
    # a successful result send an `ack` message to the queue, otherwise
    # send a nack with the option to requeue based on the result.
    #
    def process(job)
      result = job.perform
      log.info("#{queue_info} #{job.info} job.result=#{result.info}")
      if result.success?
        @consumer.ack(job.delivery_info.delivery_tag)
      else
        @consumer.nack(job.delivery_info.delivery_tag, result.requeue?)
      end
    end

    # ## `Lynr::Worker#queue_info`
    #
    # Return a String with information about the process where the worker is running
    # and the name of the consumer.
    #
    def queue_info
      "pid=#{Process.pid} queue=#{@consumer.name}"
    end

    # ## `Lynr::Worker#stop`
    #
    # Disconnect the consumer and tell the process to exit
    #
    def stop
      log.info("#{queue_info} state=stopped")
      @consumer.disconnect
      Process.exit(0)
    rescue Bunny::NetworkFailure => be
      # Do nothing. We are quitting and if this happened it is probably because
      # as similar error was raised in `#call`
    end

  end

end
