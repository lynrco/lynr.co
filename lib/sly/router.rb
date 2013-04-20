module Sly

  # TODO: This should be changed to not inherit from Rack::Cascade
  # though it should match the Rack::Cascade API for adding new 'middleware'
  class Router < Rack::Cascade

    TooMany = [501, {"Content-Type" => "text/plain"}, ["Too many matching routes."]]
    None    = [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["No matching routes."]]
    
    def initialize(apps)
      super(apps)
    end

    def call(env)
      req = Rack::Request.new(env)
      routes = apps.select { |route| route.matches_filters?(req) }
      case routes.count
        when 1
          routes[0].call(env)
        when 0
          None
        else
          TooMany
      end
    end

  end

end
