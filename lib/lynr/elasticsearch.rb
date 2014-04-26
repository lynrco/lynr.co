require 'elasticsearch'

require './lib/lynr'
require './lib/lynr/logging'

module Lynr

  # # `Lynr::Elasticsearch`
  #
  # Class to provide access to an `::Elasticsearch::Client` with consistent
  # configuration.
  #
  class Elasticsearch

    include Lynr::Logging

    # ## `Elasticsearch#client`
    #
    # Get a proprely configured `::Elasticsearch::Client`.
    #
    def client
      return @client unless @client.nil?
      @client = ::Elasticsearch::Client.new(hosts: config.uris.split(','), logger: log)
    end

    # ## `Elasticsearch#config`
    #
    # Get configuration data for use when creating `::Elasticsearch::Client`.
    #
    def config
      return @config unless @config.nil?
      @config = Lynr.config('app').elasticsearch
    end

    # ## `Elasticsearch#vehicles(query)`
    #
    # Apply `query` to the vehicles index of the Elasticsearch cluster
    # and pass along the result of the query.
    #
    def vehicles(query)
      Lynr.metrics.time('time.service:elasticsearch.vehicles') do
        client.search({
          index: 'vehicles',
          body: { query: query }
        })
      end
    end

  end

end
