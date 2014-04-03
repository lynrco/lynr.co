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

    # ## `Metrics#configured(config)`
    #
    # Check the values of `config` to determine if `Librato::Metrics` can be
    # appropriately configured.
    #
    def configured?(config=nil)
      config ||= Lynr.config('app')['librato']
      !config.nil? && config.include?('user') && config.include?('token') && config.include?('source')
    end

    # ## `Metrics#queue`
    #
    # Method to retrieve a configured instance of
    # `Librato::Metrics::Queue` to proxy method calls to.
    #
    def queue(config=nil)
      return @lynr_metrics_queue unless @lynr_metrics_queue.nil?
      config ||= Lynr.config('app').librato
      client = Librato::Metrics::Client.new
      client.authenticate(config['user'], config['token']) if configured?(config)
      @lynr_metrics_queue = client.new_queue({
        autosubmit_count: 15,
        autosubmit_interval: 90,
        prefix: 'lynr',
        source: config['source']
      })
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
