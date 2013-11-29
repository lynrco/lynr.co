require 'geocoder'

require './lib/lynr'
require './lib/lynr/model/address'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  class GeocodeAddressJob < Job

    def initialize(dealership)
      @dealership = dealership
    end

    def perform
      description = "Geocode for #{@dealership.id} -- #{@dealership.address}, #{@dealersip.postcode} --"
      results = Geocoder.search("#{@dealership.address}, #{@dealersip.postcode}")
      if (results.length == 0)
        return failure("#{description} returned no results", :no_requeue)
      end
      addresses = results.map do |result|
        Lynr::Model::Address.new(
          result.street_address,
          '',
          result.city,
          result.state,
          result.postal_code
        )
      end
      # TODO: Store address information for dealership
      Success
    rescue Geocoder::OverQueryLimitError
      failure("#{description} after limit reached. Retrying later.")
    rescue Geocoder::Error => ge
      failure("#{description} errored. #{ge.class.name} -- #{ge.message}", :no_requeue)
    end

  end

end; end;
