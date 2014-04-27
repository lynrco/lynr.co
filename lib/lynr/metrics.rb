require 'librato/metrics'

require './lib/lynr'
require './lib/lynr/logging'

module Lynr

  # # `Lynr::Metrics`
  #
  # The Metrics class wraps the Librato metrics implementation to centralize
  # handling of missing librato credentials. The class API includes a subset of
  # the public API of the `Librato::Metrics::Queue` class.
  #
  class Metrics

    include Lynr::Logging

    EMPTY_QUEUE = Object.new.tap do |o|
      def o.add(measurements) end
      def o.client() nil end
      def o.empty?() true end
      def o.submit() end
    end

    EMPTY_AGGREGATOR = Object.new.tap do |o|
      def o.add(measurements) end
      def o.client() nil end
      def o.empty?() true end
      def o.submit() end
    end

    # ## `Metrics#add(measurements)`
    #
    # Proxy to `Librato::Metrics::Queue#add` but handle the MetricsError tree
    # of errors by logging them instead of letting them propogate up.
    #
    def add(measurements)
      queue.add(measurements)
    rescue Librato::Metrics::MetricsError, Librato::Metrics::ClientError => err
      log.warn("type=metrics.add err=#{err.class.to_s} msg=#{err.message}")
    ensure
      queue.submit
    end

    # ## `Metrics#agg(measurements)`
    #
    # Proxy to `Librato::Metrics::Aggregator#add` but handle `MetricsError`s
    # by logging them.
    #
    def agg(measurements)
      aggregator.add(measurements)
    rescue Librato::Metrics::MetricsError, Librato::Metrics::ClientError => err
      log.warn("type=metrics.agg err=#{err.class.to_s} msg=#{err.message}")
    ensure
      aggregator.submit
    end

    # ## `Metrics#aggregator`
    #
    # Method to retrieve a configured instance of
    # `Librato::Metrics::Aggregator` to which measuremants can be sent.
    #
    def aggregator
      if !@lynr_metrics_aggregator.nil?
        @lynr_metrics_aggregator
      elsif
        @lynr_metrics_aggregator = Lynr::Metrics::Aggregator.new({
          client: client,
          autosubmit_count: 15,
          autosubmit_interval: 90,
          prefix: 'lynr',
          source: config['source']
        })
      else
      end
    end

    # ## `Metrics#client`
    #
    # Get a configured and authenticated `Librato::Metrics::Client`
    # instance.
    #
    def client
      client = Librato::Metrics::Client.new
      client.authenticate(config.user, config.token)
      client
    end

    # ## `Metrics#config`
    #
    # Shortcut to configuration used for metrics
    #
    def config
      @config ||= Lynr.config('app').librato
    end

    # ## `Metrics#configured?`
    #
    # Check the values of `config` to determine if `Librato::Metrics` can be
    # appropriately configured.
    #
    def configured?
      enabled? && config.include?('user') && config.include?('token') && config.include?('source')
    end

    # ## `Metrics#enabled?`
    #
    # Check the configuration says metrics are enabled
    #
    def enabled?
      !config.nil? && config.enabled?
    end

    # ## `Metrics#queue`
    #
    # Method to retrieve a configured instance of
    # `Librato::Metrics::Queue` to proxy method calls to.
    #
    def queue
      if !@lynr_metrics_queue.nil?
        @lynr_metrics_queue
      elsif configured?
        @lynr_metrics_queue = client.new_queue({
          autosubmit_count: 15,
          autosubmit_interval: 90,
          prefix: 'lynr',
          source: config['source']
        })
      else
        @lynr_metrics_queue = EMPTY_QUEUE
      end
    end

    # ## `Metrics#time(name, options)`
    #
    # Proxy to `Librato::Metrics::Queue#time` but handle the MetricsError tree
    # of errors by logging them instead of letting them propogate up.
    #
    def time(name, options={})
      start = Time.now
      yield.tap do
        duration = (Time.now - start) * 1000.0 # milliseconds
        add({ name => options.merge({ value: duration }) })
      end
    end

    alias :benchmark :time

  end

end
