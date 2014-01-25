require 'rack'
require 'set'

require './lib/sly/exceptions'

module Sly

  # # `Sly::Router`
  #
  # Rack application which dispatches requests to routes based on the route's
  # return value from `#matches_filters?` when given the request. `Router` has
  # some default responses for specific situations, see `#call(env)` for more
  # information.
  #
  class Router

    # Generic response if multiple routes match and have the same number of captures
    TooMany = [501, {"Content-Type" => "text/plain"}, ["Too many matching routes."]]
    # Generic response if no routes match
    None    = [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["No matching routes."]]

    attr_reader :routes

    # ## `Sly::Router.new(routes)`
    #
    # Creates a new `Router` instance. The new `Router` will include all `routes`
    # passed into the constructor.
    #
    def initialize(routes=[])
      @routes = []
      # Set of `route.to_s` used to quickly check if a route is included
      @has_route = Set.new
      routes.each { |route| add route }
    end

    # ## `Sly::Router#call(env)`
    #
    # Rack specified call method. Routes are filtered by whether or not they
    # return true when `matches_filters?(req)` is invoked with a `Rack::Request`
    # constructed from `env`. If a single route matches its call method is invoked
    # and the result returned as the response. If no routes match `Sly::Router::None`
    # is returned. If multiple routes return true from `matches_filters?` then the
    # routes are sorted by the number of path parameters they expect, the route with
    # expecting the fewest path parameters is invoked. If multiple routes expect the
    # same number of path parameters then `Sly::Router::TooMany` is returned.
    #
    def call(env)
      req = Rack::Request.new(env)
      routes = self.routes.select { |route| route.matches_filters?(req) }
      case routes.count
        when 1
          routes.first.call(env)
        when 0
          raise Sly::NotFoundError.new("No matching routes.")
        else
          # sort by how many captures are in the regex and take the lowest
          # if there are two routes with the lowest number of captures then
          # return the `TooMany` response
          routes = routes.sort { |a, b|
            if a.path_regex.names.length == b.path_regex.names.length
              raise Sly::TooManyRoutesError
            end
            a.path_regex.names.length <=> b.path_regex.names.length
          }
          routes.first.call(env)
      end
    end

    # ## `Sly::Router#add(route)`
    #
    # Add a route to be checked and potentially executed when a requested is being
    # dispatched.
    #
    # Aliased as `<<`.
    #
    def add(route)
      @has_route.add(route.to_s)
      @routes << route
    end

    # ## `Sly::Router#include?(route)`
    #
    # Test if this `Router` instance already checks `route` when dispatching requests.
    #
    def include?(route)
      @has_route.include? route.to_s
    end

    alias_method :<<, :add

  end

end
