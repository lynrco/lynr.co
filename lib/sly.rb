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

    def initialize(apps)
      @apps = apps
    end

    def call(env)
      Sly::DynaMap.call(env)
    end

  end

end
