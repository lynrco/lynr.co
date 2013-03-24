require 'rack'

module Sly

  class Route

    attr_reader :path

    PATH_PARAMS_REGEX = %r(/:([-_a-z]+))
    PATH_BASE_REGEX = %r((/.+?)(/:.*)?$)

    ##
    # Consruct a new `Sly::Route` 
    def initialize(verb, path, handler)
      @verb = verb
      @path = base_path(path)
      @path_r = make_r(path)
      @handler = handler
    end

    def handle(request)
      @handler.call(request).finish
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

    def base_path(uri)
      uri.match(PATH_BASE_REGEX)[1]
    end

    def make_r(uri)
      return uri if uri.is_a? Regexp
      param_names = uri.scan(PATH_PARAMS_REGEX).flatten
      Regexp.new(param_names.reduce(@path) { |base, name| base + "/(?<#{name}>[^/]+)/?" })
    end

    def matches_filters?(req)
      req.request_method == @verb && req.path =~ @path_r
    end

  end

end