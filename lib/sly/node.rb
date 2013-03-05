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
      Sly::App.add(route)
    end

    def self.get(path, method_name)
      map(path, method_name, 'GET')
    end

    def self.post(path, method_name)
      map(path, method_name, 'POST')
    end

    def initialize
      @headers = {}
    end

    def error(code = 500)
      Rack::Response.new(status = code)
    end

    def not_found
      error(404)
    end

    def render(view)
      file_name = ::File.join(Sly::App.options.root, Sly::App.options.views, view)
      str = ::File.read(file_name)
      template = ::ERB.new(str, nil, '%<>')
      Rack::Response.new(template.result(binding), 200, @headers)
    end

  end

end
