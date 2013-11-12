require 'bunny'

require './lib/lynr'
require './lib/lynr/logging'

module Lynr

  class Queue

    include Lynr::Logging

    # Options used when creating the connection
    DEFAULT_CONNECTION_OPTS = { automatically_recover: false, log_level: ::Logger::FATAL, locale: 'en_US' }
    # Options used when publishing a message
    DEFAULT_PUBLISH_OPTS = { persistent: true }
    # Options used when creating the queue
    DEFAULT_SUBSCRIBE_OPTS = { ack: true }
    # Options used when creating the queue
    DEFAULT_QUEUE_OPTS = { auto_delete: false, durable: true }

    def initialize(name, uri, opts = {})
      @attempts = 0
      @connection = Bunny.new(uri, opts.fetch(:connect, DEFAULT_CONNECTION_OPTS))
      @name = name
      @opts = opts
      @publish_opts = { routing_key: name }.merge(opts.fetch(:publish, DEFAULT_PUBLISH_OPTS))
      @queue_opts = opts.fetch(:queue, DEFAULT_QUEUE_OPTS)
      @subscribe_opts = opts.fetch(:subscribe, DEFAULT_SUBSCRIBE_OPTS)
    end

    def ack(tag)
      channel.ack(tag, false)
    end

    def disconnect
      @connection.close
      self
    end

    def nack(tag, requeue = true)
      channel.reject(tag, requeue)
    end

    def publish(msg, opts = {})
      # Duplicate @publish_opts because `Bunny::Exchange#publish` method uses
      # delete to get values
      exchange.publish(msg, @publish_opts.merge(opts))
      self
    end

    def reject(tag)
      channel.reject(tag, false)
    end

    def subscribe(opts = {}, &block)
      queue(@name).subscribe(@subscribe_opts.merge(opts), &block)
      self
    end

    def to_s
      "#<#{self.class.name}:#{object_id} #{@connection.user}@#{@connection.host}:#{@connection.port}, vhost=#{@connection.vhost}, queue=#{@name}>"
    end

    protected

    def channel
      return @channel if !@channel.nil? && @channel.active
      if @connection.open?
        @channel = @connection.create_channel
      else
        @connection = self.connected_session
        @channel = self.channel
      end
      @channel.prefetch(3)
      @channel
    end

    def connected_session
      raise Bunny::Exception.new("Too many attempts to connect") if @attempts > 3
      @connection.start
    rescue Bunny::NetworkFailure => e
      log.warn({ type: e.class.to_s, msg: e.message, status: "Retrying... #{@attempts}" })
      @attempts = @attempts + 1
      self.connected_session unless @connection.open?
    ensure
      @attempts = 0 if @connection.open?
    end

    def exchange
      channel.default_exchange
    end

    def queue(name)
      channel.queue(name, @queue_opts)
    end

  end

end
