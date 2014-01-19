require 'geocoder'
require 'georuby'

require './lib/lynr'
require './lib/lynr/model/address'
require './lib/lynr/model/dealership'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  module GeocodeJob

    # # `Lynr::Queue::GeocodeJob::Google`
    #
    # Use the Google geocoding API to get geo data for a `Lynr::Model::Dealership`'s
    # `Lynr::Model::Address`.
    #
    class Google < Job

      def initialize(dealership)
        @dealership = dealership
        @address = dealership.address
      end

      def perform
        if (!geocodable?)
          return failure("#{desc} line_one and zip not specified", :no_requeue)
        end
        results = Geocoder.search("#{@address.line_one}, #{@address.postcode}")
        if (results.length == 0)
          return failure("#{desc} returned no results", :no_requeue)
        end
        addresses = results.map(method(:address_for_result))
        # TODO: If multiple addresses, create support ticket or way to resolve

        # Do nothing if addresses are the same
        if addresses.first != @dealership.address
          dao = Lynr::Persist::DealershipDao.new
          dao.save(@dealership.set(address: addresses.first))
        end
        Success
      rescue Geocoder::OverQueryLimitError
        failure("#{desc} after limit reached. Retrying later.")
      rescue Geocoder::Error => ge
        failure("#{desc} errored. #{ge.class.name} -- #{ge.message}", :no_requeue)
      end

      protected

      def address_for_result(result)
        lnglat = result.coordinates.reverse
        Lynr::Model::Address.new(
          'line_one' => result.street_address,
          'city' => result.city,
          'state' => result.state_code,
          'zip' => result.postal_code,
          'geo' => GeoRuby::SimpleFeatures::Point.from_lon_lat(*lnglat)
        )
      end

      def desc
        "Geocode for #{@dealership.id} -- #{@address.line_one}, #{@address.postcode} --"
      end

      def geocodable?
        line_one = @address.line_one
        postcode = @address.postcode
        !(@address.nil? || line_one.nil? || line_one.empty? || postcode.nil? || postcode.empty?)
      end

    end

  end

end; end;
