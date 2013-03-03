require 'rack'

module Sly

  class Route

    attr_reader :path

    ##
    # Consruct a new `Sly::Route` 
    def initialize(verb, path, handler)
      @verb = verb
      @path = path
      @path_r = make_r(path)
      @handler = handler
    end

    def handle(request)
      @handler.call(request)
    end

    def call(env)
      # TODO: This is going to get expensive in large apps
      request = Rack::Request.new(env)
      if (matches_filters?(request))
        handle(request)
      else
        body = "Wrong Route for #{request.path}\n"
        headers = {
          'Content-Type' => 'text/plain',
          'Content-Length' => body.size.to_s,
          'X-Cascade' => 'pass'
        }
        # TODO: This is going to get expensive in large apps
        res = Rack::Response.new(body = [body], status = 404, header = headers)
        res.finish
      end
    end

    private

    def matches_filters?(req)
      req.request_method == @verb && req.path =~ @path_r
    end

    def make_r(p)
      return p if p.is_a? Regexp
      %r(^#{p.to_s}(/.*)?$)
    end

  end

end
