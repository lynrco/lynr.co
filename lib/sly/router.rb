require 'rack'

require 'sly/exceptions'

module Sly

  class Router

    TooMany = [501, {"Content-Type" => "text/plain"}, ["Too many matching routes."]]
    None    = [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["No matching routes."]]

    attr_reader :routes
    
    def initialize(routes)
      @routes = []
      @has_route = {}
      routes.each { |route| add route }
    end

    def call(env)
      req = Rack::Request.new(env)
      routes = self.routes.select { |route| route.matches_filters?(req) }
      case routes.count
        when 1
          routes[0].call(env)
        when 0
          None
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
          routes[0].call(env)
      end
    rescue Sly::TooManyRoutesError => tmre
      TooMany
    end

    def add(route)
      @has_route[route.to_s] = true
      @routes << route
    end

    def include?(route)
      @has_route.include? route.to_s
    end

    alias_method :<<, :add

  end

end
