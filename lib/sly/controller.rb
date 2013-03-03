require 'rack'

require './lib/sly/route'

module Sly

  class Controller

    ##
    # Mapped methods must return an Array with the form
    # `[status_code (int), headers (Hash), body (Iterable)]`. This may be
    # recognized as the result of `Rack::Response#finish`
    #
    def self.map(path, method_name, verb='GET')
      if method_name.is_a? Sly::Route
        route = method_name
        DynaMap.map(path, route)
      else
        method = method_name.to_sym
        DynaMap.map(path, Route.new(verb, path, lambda { |req| self.new.send(method, req) }))
      end
    end

    def error(code = 500)
      Rack::Response.new(status = code)
    end

    def not_found
      error(404)
    end

  end

end
