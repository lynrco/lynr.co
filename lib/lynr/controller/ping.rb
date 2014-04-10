require './lib/lynr/controller'
require './lib/lynr/controller/base'

module Lynr::Controller

  class Ping < Lynr::Controller::Base

    get  '/ping', :ping

    def headers
      super.merge({
        'Content-Type' => 'text/plain; charset=utf-8',
      })
    end

    def ping(req)
      Rack::Response.new('PONG', 200, headers)
    end

  end

end
