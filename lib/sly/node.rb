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
  class Node

    ##
    # Mapped methods must return an object that will respond to `:finish` message
    # with the form # `[status_code (int), headers (Hash), body (Iterable)]`.
    # This may be recognized as the contract of `Rack::Response`
    #
    def self.map(path, method_name, verb='GET')
      route = nil
      if method_name.is_a? Sly::Route
        route = method_name
      else
        method = method_name.to_sym
        route = create_route(path, method_name, verb)
      end
      Sly::App.add(route)
    end

    ##
    # Delegates to `Sly::Node#map` with a 'GET' verb
    def self.get(path, method_name)
      map(path, method_name, 'GET')
    end

    ##
    # Delegates to `Sly::Node#map` with a 'POST' verb
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
    def self.create_route(path, method_name, verb)
      method = method_name.to_sym
      Route.new(verb, path, lambda { |req| self.new.send(method, req) })
    end

    ##
    # ## `Sly::Node.new`
    #
    # Create a new Node instance making sure `@headers` is initialized
    #
    def initialize
      @headers = {} if @headers.nil?
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
    # Creates an error Response object. This is included to help define the API
    # of a controller and is intended to be overwritten by the extending
    # application in a parent controller.
    #
    # ### Params
    #
    # * `code` response status code. *Default*: 302
    #
    # ### Returns
    #
    # A `Rack::Response` instance
    #
    def error(code = 500)
      Rack::Response.new(status = code)
    end

    ##
    # ## `Sly::Node#not_found`
    #
    # Creates a 404 response object. This is included to help define the API
    # of a controller and is intended to be overwritten by the extending
    # application in a parent controller.
    #
    # ### Returns
    #
    # A `Rack::Response` instance
    #
    def not_found
      error(404)
    end

  end

end
