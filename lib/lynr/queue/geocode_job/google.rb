require 'geocoder'
require 'georuby'

require './lib/lynr'
require './lib/lynr/model/address'
require './lib/lynr/model/dealership'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  module GeocodeJob

    class Google < Job

      def initialize(dealership)
        @dealership = dealership
      end

      def perform
        description = "Geocode for #{@dealership.id} -- #{@dealership.address.line_one}, #{@dealersip.address.postcode} --"
        results = Geocoder.search("#{@dealership.address.line_one}, #{@dealersip.address.postcode}")
        if (results.length == 0)
          return failure("#{description} returned no results", :no_requeue)
        end
        addresses = results.map do |result|
          lnglat = result.coordinates.reverse
          Lynr::Model::Address.new(
            'line_one' => result.street_address,
            'city' => result.city,
            'state' => result.state_code,
            'zip' => result.postal_code,
            'geo' => GeoRuby::SimpleFeatures::Point.from_lon_lat(*lnglat)
          )
        end
        dao = Lynr::Persist::DealershipDao.new
        dao.save(@dealership.set(address: addresses.first) if addresses.first != @dealership.address
        Success
      rescue Geocoder::OverQueryLimitError
        failure("#{description} after limit reached. Retrying later.")
      rescue Geocoder::Error => ge
        failure("#{description} errored. #{ge.class.name} -- #{ge.message}", :no_requeue)
      end

    end

  end

end; end;
