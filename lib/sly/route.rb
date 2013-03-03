require 'rack'

module Sly

  class Route

    ##
    # Consruct a new `Sly::Route` 
    def initialize(verb, path, handler)
      @verb = verb
      @path = path
      @handler = handler
    end

    def handle(request)
      @handler.call(request)
    end

    def call(env)
      request = Rack::Request.new(env)
      if (matches_filters?(request))
        handle(request)
      else
        bod = ["Wrong Route for #{request.path}"]
        res = Rack::Response.new(body = bod, status = 404)
        res['Content-Type'] = 'text/plain'
        res['Content-Length'] = bod[0].length.to_s
        res.finish
      end
    end

    def matches_filters?(req)
      req.request_method == @verb && req.path == @path
    end

  end

end
