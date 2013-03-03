require 'rack'

module Sly

  class Route

    ##
    # Consruct a new `Sly::Route` 
    def initialize(verb, path, handler)
      @verb = verb
      @path = make_r(path)
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
        res['X-Cascade'] = 'pass'
        res.finish
      end
    end

    private

    def matches_filters?(req)
      req.request_method == @verb && req.path =~ @path
    end

    def make_r(p)
      return p if p.is_a? Regexp
      %r(^#{p.to_s}(/.*)?$)
    end

  end

end
