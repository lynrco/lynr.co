require 'rack'

require './lib/sly/route'
require './lib/sly/view/erb'

module Sly

  class Node

    include ERB::Util

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

    ##
    # Create a new Node instance making sure `@headers` is initialized
    #
    def initialize
      @headers = {} if @headers.nil?
    end

    ##
    # This might be dangerous but it doesn't seem like it ought to be. This is
    # a method to proxy to the inherited binding method to expose it in the
    # public API for Sly::Node because Sly::View::* instances will need access
    # to it.
    #
    # See `Kernel#binding`
    #
    def ctx
      binding
    end

    def error(code = 500)
      Rack::Response.new(status = code)
    end

    def not_found
      error(404)
    end

    def render(view, opts={})
      template = ::File.join(Sly::App.options.root, Sly::App.options.views, view.to_s)
      layout = ::File.join(Sly::App.options.root, Sly::App.options.layouts, opts[:layout].to_s) if opts.has_key?(:layout)
      view = Sly::View::Erb.new(template, { layout: layout, context: self })
      Rack::Response.new(view.result, 200, @headers)
    end

    def render_partial(path)
      partial = ::File.join(Sly::App.options.root, Sly::App.options.partials, path.to_s)
      partial_view = Sly::View::Erb.new(partial, { context: self })
      partial_view.result
    end

  end

end
