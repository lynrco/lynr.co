require 'rack'

require 'sly/request'

module Sly

  class Route

    Unimplemented = [501, {"Content-Type" => "text/plain"}, ["Unimplemented."]]

    attr_reader :path, :path_regex

    PATH_PARAMS_REGEX = %r(/:([-_a-z]+))
    PATH_BASE_REGEX = %r((/.+?)(/:.*)?$)

    ##
    # # `Sly::Route.new`
    #
    # Consruct a new `Sly::Route`
    #
    # ## Params
    #
    # * `verb` HTTP verb this route may process
    # * `path` Path pattern URIs must match
    # * `handler` lambda use to process the route. `handler` may be `nil`
    #   if `Route` is subclassed and the handle method is overridden.
    #
    def initialize(verb, path, handler=nil)
      @verb = verb.upcase
      # TODO: if path is a regex base path should be '/' and don't create a regex
      @path = base_path(path)
      @path_full = path
      @path_regex = make_r
      @handler = handler
    end

    ##
    # # `Sly::Route#handle`
    #
    # Process the given request returning an array of the form
    # [`status`, `headers`, `body`]. `status` is an HTTP response code.
    # `headers` is a `Hash` of header name to header value. `body` is an
    # iterable response body.
    #
    # ## Params
    #
    # * `request` is an instance of `Sly::Request` created from the rack environment
    #
    # ## Returns
    #
    # [`status`, `headers`, `body`]
    #
    def handle(request)
      response = @handler.call(request)
      if response.is_a? Rack::Response
        response.finish
      elsif response.is_a? Array
        response
      else
        Sly::Route::Unimplemented
      end
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
