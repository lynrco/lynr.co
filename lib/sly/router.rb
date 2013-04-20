require 'rack'

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
          TooMany
      end
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
