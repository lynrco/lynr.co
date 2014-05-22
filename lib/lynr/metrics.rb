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

    EMPTY_PROCESSOR = Object.new.tap do |o|
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
      measure(queue, 'add', measurements)
    end

    # ## `Metrics#agg(measurements)`
    #
    # Proxy to `Librato::Metrics::Aggregator#add` but handle `MetricsError`s
    # by logging them.
    #
    def agg(measurements)
      measure(aggregator, 'agg', measurements)
    end

    # ## `Metrics#aggregator`
    #
    # Method to retrieve a configured instance of
    # `Librato::Metrics::Aggregator` to which measuremants can be sent.
    #
    def aggregator
      if !@lynr_metrics_aggregator.nil?
        @lynr_metrics_queue
      elsif configured?
        @lynr_metrics_aggregator = Librato::Metrics::Aggregator.new(processor_options)
      else
        @lynr_metrics_aggregator = EMPTY_PROCESSOR
      end
    end

    # ## `Metrics#client`
    #
    # Get a configured and authenticated `Librato::Metrics::Client`
    # instance.
    #
    def client
      return @client unless @client.nil?
      @client = Librato::Metrics::Client.new
      @client.authenticate(config.user, config.token)
      @client
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

    # ## `Metrics#measure(processor, type, measurements)`
    #
    # Submit `measurements` to `processor` and if they fail identify the
    # `measurements` as `type` in the log.
    #
    def measure(processor, type, measurements)
      processor.add(measurements)
    rescue Librato::Metrics::ClientError
      timeshift(processor)
    rescue Librato::Metrics::MetricsError => err
      log.warn("type=metrics.#{type} err=#{err.class.to_s} msg=#{err.message}")
    end

    # ## `Metrics#processor_options`
    #
    # The options to give to Librato processor instances.
    #
    def processor_options
      @_processor_options ||= {
        client: client,
        autosubmit_interval: 60,
        prefix: 'lynr',
        source: config['source']
      }
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
        @lynr_metrics_queue = Librato::Metrics::Queue.new(processor_options)
      else
        @lynr_metrics_queue = EMPTY_PROCESSOR
      end
    end

    # ## `Metrics#remove_prefix(name)`
    #
    # Internal: Remove `#processor_options[:prefix]` from the start of
    # `name`.
    #
    # * `name` - `String` from which to remove `#processor_options[:prefix]`
    #
    # Returns `name` without `#processor_options[:prefix]`.
    #
    def remove_prefix(name)
      if !name.nil?
        name.gsub(/\A#{processor_options[:prefix]}\./, '')
      else
        name
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

    # ## `Metrics#timeshift(processor)`
    #
    # Internal: When metrics fail to submit and raise a `ClientError`
    # (rescued in `#measure`) attempt to re-submit the metrics data with
    # older measurements timeshifted to the oldest allowable collection
    # time (120 minutes ago). If the submission fails again for any reason
    # clear the data from `processor` and log the error.
    #
    # NOTE: This is basically impossible to test without substantial
    # mocking, it is side-effects all the way down.
    #
    # * processor - `Librato::Metrics::Aggregator` or `Librato::Metrics::Queue`
    #               containing measurements to be sent to the Librato API
    #
    # Returns Boolean result from `Librato::Metrics::Processor#submit`
    # which is called after `processor` measurements have been
    # timeshifted and re-added to `processor`.
    #
    def timeshift(processor)
      max_age = (Time.now - (60 * 119)).to_i # Go back just under 120 minutes
      gauges = processor.queued.fetch(:gauges, []).dup
      processor.clear
      gauges.each do |measurement|
        name = remove_prefix(measurement.delete(:name))
        measure_time = measurement[:measure_time]
        if !measure_time.nil? && measure_time < max_age
          measurement[:measure_time] = max_age
        end
        processor.add(name => measurement)
      end
      processor.submit
    rescue Librato::Metrics::MetricsError, Librato::Metrics::ClientError => err
      log.warn("type=metrics.timeshift err=#{err.class.to_s} msg=#{err.message}")
      processor.clear
    end

  end

end
