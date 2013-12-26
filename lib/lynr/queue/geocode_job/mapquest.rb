require 'rest-client'

require './lib/lynr'
require './lib/lynr/model/dealership'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  module GeocodeJob

    class MapQuest < Job

      URL = 'http://open.mapquestapi.com/geocoding/v1/address?key='

      def initialize(dealership, appkey)
        @dealership = dealership
        @appkey = appkey
        @address = @dealership.address
      end

      def perform
        return failure("Address is not valid", :no_requeue) if !valid?
        data = {
          'location' => {
            'street' => @address.line_one,
            'postalCode' => @address.zip,
            'country' => 'US'
          }
        }
        headers = {
          'Content-type' => 'application/json;charset="utf-8"',
          'Accept' => 'application/json',
          'Cache-Control' => 'no-cache',
          'Pragma' => 'no-cache',
          'Content-length' => data.to_json.length
        }
        url = ""
        @response = RestClient.post url, data.to_json, headers
        # TODO:
        # Extract the geo data from @response
        # If no geo data check response for error codes
        # Set the geo data on @address
        # Save the new address information to @dealership
        # If ALL of those steps succeeded then Success
        Success
      rescue RestClient::Exception => rce
        log.warn("Post to #{url} with #{data} failed... #{rce.to_s}")
        failure("Post to #{url} failed. #{rce.to_s}")
      end

      def to_s
        "#<#{self.class.name}:#{object_id} dealership=#{@dealership.id}, name=#{@dealership.name}>"
      end

      private

      def geodata
        json = JSON.parse(@response)
        results = json['results'][0] || {}
        locations = results['locations'] || []
      end

      def valid?
        !@address.nil? &&
            @address.line_one.is_a? String &&
            @address.zip.is_a? String &&
            @address.line_one.length > 3 &&
            @address.zip.length >= 5
      end

    end

  end

end; end;
