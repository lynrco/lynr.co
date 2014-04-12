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
require './lib/lynr/queue/index_vehicle_job'
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

    autoload :Job, './lib/lynr/worker/job'

    include Lynr::Logging

    attr_reader :config, :queue_name

    # ## `Lynr::Worker.new(queue_name)`
    #
    # Create a new `Worker` with `queue_name` as the name of the `JobQueue` used
    # to process the `Worker`'s messages.
    #
    def initialize(queue_name)
      @config = Lynr.config('app')
      @queue_name = queue_name
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
      consumer.subscribe({ block: true }, &method(:process))
    rescue SystemExit => sysexit
      stop unless sysexit.success?
    rescue Exception => e
      log.error("#{queue_info} state=error message=#{e.message} type=#{e.class.name}")
      stop
    end

    # ## `Lynr::Worker#consumer`
    #
    # Defines the type of `Lynr::Queue` to for which this `Worker`
    # consumes messages. This method must be implemented by subclasses.
    # `#consumer` is expected to return the same consumer every time.
    #
    def consumer
      raise NoMethodError.new("`Lynr::Worker#consumer` must be defined in subclass")
    end

    # ## `Lynr::Worker#process(*args)`
    #
    # Perform the work for this `Worker`. This method is the one that
    # makes the action happen and must be implemented by subclasses.
    #
    def process(*args)
      raise NoMethodError.new("`Lynr::Worker#process` must be defined in subclass")
    end

    # ## `Lynr::Worker#queue_info`
    #
    # Return a String with information about the process where the worker is running
    # and the name of the consumer.
    #
    def queue_info
      "pid=#{Process.pid} queue=#{queue_name}"
    end

    # ## `Lynr::Worker#stop`
    #
    # Disconnect the consumer and tell the process to exit
    #
    def stop
      log.info("#{queue_info} state=stopped")
      consumer.disconnect
      Process.exit(0)
    rescue Bunny::NetworkFailure => be
      # Do nothing. We are quitting and if this happened it is probably because
      # as similar error was raised in `#call`
    end

  end

end
