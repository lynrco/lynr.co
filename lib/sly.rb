require 'rack'
require 'innate'

require './lib/sly/node'
require './lib/sly/route'
require './lib/sly/urlmap'

module Sly

  DynaMap = Sly::URLMap.new
  Cascade = Rack::Cascade.new([])

  class App

    def self.add(route)
      Sly::DynaMap.map(route.path, route)
      Sly::Cascade.add(route)
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      res = Sly::DynaMap.call(env)
      # Behave like a cascade
      # TODO: Make this an option
      if (res[0].to_i == 404)
        @app.call(env)
      else
        res
      end
    end

  end

end
