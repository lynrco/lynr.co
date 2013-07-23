require 'rack'

require 'sly/request'

module Sly

  class Route

    attr_reader :path, :path_regex

    PATH_PARAMS_REGEX = %r(/:([-_a-z]+))
    PATH_BASE_REGEX = %r((/.+?)(/:.*)?$)

    ##
    # Consruct a new `Sly::Route` 
    def initialize(verb, path, handler)
      @verb = verb.upcase
      @path = base_path(path)
      @path_full = path
      @path_regex = make_r
      @handler = handler
    end

    def handle(request)
      @handler.call(request).finish
    end

    def call(env)
      # TODO: This is going to get expensive in large apps
      request = Sly::Request.new(env, @path_regex)
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

    def Route.make_r(uri)
      return uri if uri.is_a? Regexp
      param_names = uri.scan(PATH_PARAMS_REGEX).flatten
      patterns = uri.split('/').map do |part|
        name = part.sub(':', '')
        (param_names.include?(name) && "(?<#{name}>[^/]+)") || part
      end
      Regexp.new("\\A#{patterns.join('/')}\\Z")
    end

    def make_r
      return @path_full if @path_full.is_a? Regexp
      return @path_regex if @path_regex.is_a? Regexp
      @path_regex = Route.make_r(@path_full)
    end

    def matches_filters?(req)
      req.request_method == @verb && req.path =~ @path_regex
    end

    def to_s
      "#{@verb.rjust(7, ' ')}: #{@path_full}"
    end

  end

end
