require 'bunny'

require './lib/lynr'
require './lib/lynr/logging'

module Lynr

  # # `Lynr::Queue`
  #
  # Basic interface to AMQP channels and exhanges. Provides a way to publish and
  # subscribe to messages as well as a way to ack, nack or reject messages.
  #
  class Queue

    include Lynr::Logging

    attr_reader :name

    # Options used when creating the connection
    DEFAULT_CONNECTION_OPTS = {
      automatically_recover: false,
      log_level: ::Logger::FATAL,
      locale: 'en_US'
    }
    # Options used when publishing a message
    DEFAULT_PUBLISH_OPTS = { persistent: true }
    # Options used when creating the queue
    DEFAULT_SUBSCRIBE_OPTS = { ack: true }
    # Options used when creating the queue
    DEFAULT_QUEUE_OPTS = { auto_delete: false, durable: true }

    # ## `Lynr::Queue.new(name, uri, opts)`
    #
    # Create a new queue called `name` by connecting to `uri` with `opts`.
    #
    # ### Options
    #
    # * `:connect` options to pass to AMQP when establishing a connection,
    #     merged into `Queue::DEFAULT_CONNECTION_OPTS`
    # * `:queue` used when creating a new AMQP queue to publish or subscribe to,
    #     merged into `Queue::DEFAULT_QUEUE_OPTS`
    # * `:publish` used when publishing messages, merged into
    #     `Queue::DEFAULT_PUBLISH_OPTS`
    # * `:subscribe` used when subscibing to messages, merged into
    #     `Queue::DEFAULT_SUBSCRIBE_OPTS`
    #
    def initialize(name, uri, opts = {})
      @attempts = 0
      @connection = Bunny.new(uri, fetch_options(opts, :connect, DEFAULT_CONNECTION_OPTS))
      @name = name
      @opts = opts
      @publish_opts = { routing_key: name }.merge(fetch_options(opts, :publish, DEFAULT_PUBLISH_OPTS))
      @queue_opts = fetch_options(opts, :queue, DEFAULT_QUEUE_OPTS)
      @subscribe_opts = fetch_options(opts, :subscribe, DEFAULT_SUBSCRIBE_OPTS)
    end

    # ## `Lynr::Queue#ack(tag)`
    #
    # Acknowledge a message as being delivered and processed such that it can be
    # removed from the queue.
    #
    def ack(tag)
      channel.ack(tag, false)
    end

    # ## `Lynr::Queue#disconnect`
    #
    # Close the connection to AMQP and return a reference to self.
    #
    def disconnect
      @connection.close
      self
    end

    # ## `Lynr::Queue#nack(tag, requeue)`
    #
    # Tell the queue a message has been received but was not processed successfully
    # and whether or not it should be put back on the queue. If `requeue` is not
    # provided and false the message is requeued.
    #
    def nack(tag, requeue = true)
      channel.reject(tag, requeue)
    end

    # ## `Lynr::Queue#publish(msg, opts)`
    #
    # Add `msg` to the queue represented by this instance using `opts` to override
    # the `:publish` options provided when constructing `Queue`.
    #
    def publish(msg, opts = {})
      # Duplicate @publish_opts because `Bunny::Exchange#publish` method uses
      # delete to get values
      exchange.publish(msg, @publish_opts.merge(opts))
      self
    end

    # ## `Lynr::Queue#reject(tag)`
    #
    # Reject message represented by tag and do not requeue it.
    #
    def reject(tag)
      channel.reject(tag, false)
    end

    # ## `Lynr::Queue#subscribe(opts, &block)`
    #
    # Subscribe to messages published to queue and handle them with `block`. `opts`
    # are used to override the `:subscribe` options provided when constructing `Queue`.
    #
    def subscribe(opts = {}, &block)
      queue(@name).subscribe(@subscribe_opts.merge(opts), &block)
      self
    end

    # ## `Lynr::Queue#to_s`
    #
    # Create a string representation of this instance.
    #
    def to_s
      "#<#{self.class.name}:#{object_id} #{connection_info}, queue=#{@name}>"
    end

    protected

    # ## `Lynr::Queue#channel`
    #
    # *Protected* method to get a reference to an open AMQP channel.
    #
    def channel
      return @channel if !@channel.nil? && @channel.active
      if @connection.open?
        @channel = @connection.create_channel
      else
        @connection = self.connected_session
        @channel = self.channel
      end
      @channel.prefetch(3)
      @channel.on_uncaught_exception(&method(:process_uncaught_exception))
      @channel
    end

    # ## `Lynr::Queue#connected_session`
    #
    # *Protected* method to get a reference to the AMQP connection and start it.
    # Raises a `Bunny::Exception` if queue has attempted to connect more than 3 times.
    #
    def connected_session
      raise Bunny::Exception.new("Too many attempts to connect") if @attempts > 3
      @connection.start
    rescue Bunny::NetworkFailure => e
      log.warn("type=measure.queue.attempt connection=#{connection_info} msg=#{e.message} status=retry")
      @attempts = @attempts + 1
      self.connected_session unless @connection.open?
    ensure
      @attempts = 0 if @connection.open?
    end

    # ## `Lynr::Queue#exchange`
    #
    # *Protected* method to access the default exchange for the connected AMQP channel.
    #
    def exchange
      channel.default_exchange
    end

    def process_uncaught_exception(e, consumer)
      log.error("type=error.uncaught name=#{e.class.name} message=#{e.message}")
    end

    # ## `Lynr::Queue#queue(name)`
    #
    # *Protected* method to get a queue reference identified by `name` on the active
    # channel with `:queue` options provided when constructing the instance.
    #
    def queue(name)
      channel.queue(name, @queue_opts)
    end

    private

    # ## `Lynr::Queue#connection_info`
    #
    # *Private* method to get some basic information about this instance.
    #
    def connection_info
      "#{@connection.user}@#{@connection.host}:#{@connection.port} vhost=#{@connection.vhost}"
    end

    # ## `Lynr::Queue#fetch_options(opts, type, defaults)`
    #
    # *Private* method to merge `opts.fetch(type)` into defaults.
    #
    def fetch_options(opts, type, defaults)
      options = opts.fetch(type, defaults)
      defaults.merge(options || {})
    end

  end

end
