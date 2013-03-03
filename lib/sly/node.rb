require 'rack'

require './lib/sly/route'

module Sly

  class Node

    ##
    # Mapped methods must return an Array with the form
    # `[status_code (int), headers (Hash), body (Iterable)]`. This may be
    # recognized as the result of `Rack::Response#finish`
    #
    def self.map(path, method_name, verb='GET')
      route = nil
      if method_name.is_a? Sly::Route
        route = method_name
      else
        method = method_name.to_sym
        route = Route.new(verb, path, lambda { |req| self.new.send(method, req) })
      end
      Sly::App.add(path, route)
    end

    def self.get(path, method_name)
      map(path, method_name, 'GET')
    end

    def self.post(path, method_name)
      map(path, method_name, 'POST')
    end

    def error(code = 500)
      Rack::Response.new(status = code)
    end

    def not_found
      error(404)
    end

  end

end
