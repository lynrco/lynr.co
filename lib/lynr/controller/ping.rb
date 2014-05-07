require './lib/lynr/controller'
require './lib/lynr/controller/base'
require './lib/lynr/metrics'

module Lynr::Controller

  # # `Lynr::Controller::Ping`
  #
  # Ping controller for checking the server is alive and responding to
  # requests.
  #
  class Ping < Lynr::Controller::Base

    get  '/ping', :ping

    # ## `Ping#headers`
    #
    # The headers to use when sending a `Rack::Response`.
    #
    def headers
      super.merge({
        'Content-Type' => 'text/plain; charset=utf-8',
      })
    end

    # ## `Ping#ping(req)`
    #
    # Handler for the '/ping' URI.
    #
    def ping(req)
      Lynr.metrics.time('time.render:ping') do
        Rack::Response.new('PONG', 200, headers)
      end
    end

  end

end
