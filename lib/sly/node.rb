require 'rack'

require './lib/sly/route'
require './lib/sly/view/erb'

module Sly

  ##
  # # Sly::Node
  #
  # Nodes are responsible for handling and creating Route definitions and
  # adding them to the Rack application to be used in processing.
  #
  # `Sly::Node` is meant to be extended by controller type objects in an
  # application.
  #
  class Node

    ##
    # ## `Sly::Node.map`
    #
    # Creates a `Sly::Route` for the given path and registers the `Route` with
    # `Sly` which is the Middleware used with a Sly application.
    #
    # Mapped methods must return an object that will respond to `:finish`
    # message/method with the form
    # `[status_code (int), headers (Hash), body (Iterable)]`.
    #
    # This may be recognized as the contract of `Rack::Response`
    #
    # ### Params
    #
    # * `path` the request must match this string for the route to be considered
    #   for handling
    # * `method_name` String or Symbol identifying the controller method to be
    #   invoked
    # * `verb` to match when determining if the created route can handles the
    #   request. *Default*: GET
    #
    # ### Returns
    #
    # The result of `Sly.add` which is, thus far, indeterminate
    #
    def self.map(path, method_name, verb='GET')
      route = nil
      if method_name.is_a? Sly::Route
        route = method_name
      else
        method = method_name.to_sym
        route = create_route(path, method_name, verb)
      end
      Sly.add(route)
    end

    ##
    # ## `Sly::Node.get`
    #
    # Delegates to `Sly::Node#map` with a 'GET' verb
    #
    def self.get(path, method_name, opts={})
      map(path, method_name, 'GET')
      map(path, method_name, 'HEAD') if opts.fetch(:head, true)
    end

    ##
    # ## `Sly::Node.post`
    #
    # Delegates to `Sly::Node#map` with a 'POST' verb
    #
    def self.post(path, method_name)
      map(path, method_name, 'POST')
    end

    ##
    # ## `Sly::Node.create_route`
    #
    # Create a Route based on the path, method_name and verb
    #
    # `Sly::Node.create_route` is a hook or override point so Route creation
    # can be customized either with a new Route class or with special logic.
    #
    # The created `Route` instances are Rack middleware. In addition to the
    # standard `#call` method they must have a `#path` method which identifies
    # the base path for which the Route should process requests.
    #
    # ### Params
    #
    # * `path` the request must match this string for the route to be considered
    #   for handling
    # * `method_name` String or Symbol identifying the controller method to be
    #   invoked
    # * `verb` to match when determining if the created route can handles the
    #   request
    #
    # ### Returns
    #
    # A newly created `Sly::Route` instance
    #
    def self.create_route(path, method_name, verb)
      method = method_name.to_sym
      Route.new(verb, path, lambda { |req| self.new.send(method, req) })
    end

    ##
    # ## `Sly::Node#ctx`
    #
    # This might be dangerous but it doesn't seem like it ought to be. This is
    # a method to proxy to the inherited binding method to expose it in the
    # public API for Sly::Node because Sly::View::* instances will need access
    # to it.
    #
    # *See* `Kernel#binding`
    #
    def ctx
      binding
    end

    ##
    # ## `Sly::Node#error`
    #
    # Raises a `Sly::HttpError` instance. This is included to help define the API
    # of a controller and is intended to be overwritten by the extending
    # application in a parent controller or for the invoking application to
    # rescue the `HttpError`.
    #
    # ### Params
    #
    # * `code` response status code. *Default*: 500
    #
    def error(code = 500)
      raise Sly::HttpError.new(code)
    end

    ##
    # ## `Sly::Node#headers`
    #
    # Provide access to the set of headers to be used in responses from this
    # node.
    #
    def headers
      {}
    end

    ##
    # ## `Sly::Node#not_found`
    #
    # Raises a `Sly::NotFoundError`. This is included to help define the API
    # of a controller and is intended to be overwritten by the extending
    # application in a parent controller or for the invoking application to
    # rescue the `HttpError`
    #
    def not_found
      raise Sly::NotFoundError.new
    end

    ##
    # ## `Sly::Node#redirect`
    #
    # Creates a `Rack::Response` instance which a redirect
    # status and the specified destination.
    #
    # ### Params
    #
    # * `target` value for the Location header
    # * `status` response status code. *Default*: 302
    # * `headers` Hash of headers to set. *Default*: {}
    #
    # ### Returns
    #
    # A `Rack::Response` instance
    #
    def redirect(target, status=302, headers={})
      Rack::Response.new.tap do |res|
        res.redirect(target, status)
        headers.each { |name, value| res[name] = value }
      end
    end

  end

end
