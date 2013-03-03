require 'rack'
require 'innate'

require './lib/sly/node'
require './lib/sly/route'

module Sly

  DynaMap = Innate::URLMap.new
  Cascade = Rack::Cascade.new([])

  class App

    def self.add(path, route)
      Sly::DynaMap.map(path, route)
      Sly::Cascade.add(route)
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      res = Sly::DynaMap.call(env)
      if (res[0].to_i == 404)
        @app.call(env)
      else
        res
      end
    end

  end

end
