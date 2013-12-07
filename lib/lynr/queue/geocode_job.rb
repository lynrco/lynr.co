require 'rest-client'

require './lib/lynr'
require './lib/lynr/queue'
require './lib/lynr/queue/geocode_job/google'
require './lib/lynr/queue/geocode_job/mapquest'

module Lynr; class Queue;

  module GeocodeJob

    UA = 'Lynr Address Geocoder - http://www.lynr.co'

  end

end; end;
