require 'rack'

require './lib/sly/request'

module Sly

  # # `Sly::Route`
  #
  # `Route` is a class to transform a request into a response. A `Route` implements
  # the Rack middleware interface. Each Route is composed of an HTTP verb, a request
  # path and a handler.
  #
  class Route

    # Response to provide if handler doesn't return a `Rack::Response` or an Array
    Unimplemented = [501, {"Content-Type" => "text/plain"}, ["Unimplemented."]]

    attr_reader :path, :path_regex

    PATH_PARAMS_REGEX = %r(/:([-_a-z]+))
    PATH_BASE_REGEX = %r((/.+?)(/(:.*)|\*)?$)

    # ## `Sly::Route.new(verb, path, handler)`
    #
    # Consruct a new `Sly::Route`
    #
    # ### Params
    #
    # * `verb` HTTP verb this route may process
    # * `path` Path pattern URIs must match
    # * `handler` lambda use to process the route. `handler` may be `nil`
    #     if `Route` is subclassed and the handle method is overridden.
    #
    def initialize(verb, path, handler=nil)
      @verb = verb.upcase
      # TODO: if path is a regex base path should be '/' and don't create a regex
      @path = base_path(path)
      @path_full = path
      @path_regex = make_r
      @handler = handler
    end

    # ## `Sly::Route#handle(request)`
    #
    # Process the given request returning an array of the form
    # [`status`, `headers`, `body`]. `status` is an HTTP response code.
    # `headers` is a `Hash` of header name to header value. `body` is an
    # iterable response body.
    #
    # ### Params
    #
    # * `request` is an instance of `Sly::Request` created from the rack environment
    #
    # ### Returns
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

    # ## `Sly::Route#call(env)`
    #
    # Entry point to `Route` processing, takes the Rack `ENV` and transforms it
    # into a response `Rack` understands.
    #
    def call(env)
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

    # ## `Sly::Route#base_path(uri)`
    #
    # Takes a `uri` and and matches it against `Sly::Route::PATH_BASE_REGEX` to
    # get the base of the `uri`. The base of the `uri` is the portione from the
    # first '/' up to the first path parameter.
    #
    def base_path(uri)
      matched = uri.match(PATH_BASE_REGEX)
      (matched && matched[1]) || '/'
    end

    # ## `Sly::Route.make_r(uri)`
    #
    # Takes a `uri` pattern with path parameters and provides a regular expression
    # useable to extract the path parameter values into capture groups.
    #
    def self.make_r(uri)
      return uri if uri.is_a? Regexp
      return %r(\A/\Z) if uri == '/'
      param_names = uri.scan(PATH_PARAMS_REGEX).flatten
      patterns = uri.split('/').reject { |p| p == '*' }.map do |part|
        name = part.sub(':', '')
        (param_names.include?(name) && "(?<#{name}>[^/]+)") || part
      end
      tail = uri.end_with?('/*') && "/(?<_tail_>.+)" || ''
      Regexp.new("\\A#{patterns.join('/')}#{tail}\\Z")
    end

    # ## `Sly::Route#make_r`
    #
    # Uses `path` provided to constructor to create capture groups for path
    # parameters.
    #
    def make_r
      return @path_full if @path_full.is_a? Regexp
      return @path_regex if @path_regex.is_a? Regexp
      @path_regex = Route.make_r(@path_full)
    end

    # ## `Sly::Route#matchs_filters?(req)`
    #
    # Check to see if req is able meant to process `req`.
    #
    def matches_filters?(req)
      req.request_method == @verb && req.path =~ @path_regex
    end

    # ## `Sly::Route#to_s`
    #
    # A `String` representation of `Route` describing the specification of the `Route`
    # including the verb and path.
    #
    def to_s
      "#{@verb.rjust(7, ' ')}: #{@path_full}"
    end

  end

end
