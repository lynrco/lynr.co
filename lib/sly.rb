require 'rack'
require 'innate'

require './lib/sly/node'
require './lib/sly/route'
require './lib/sly/urlmap'

module Sly

  DynaMap = Sly::URLMap.new
  Cascade = Rack::Cascade.new([])

  class App

    include Innate::Optioned

    options.dsl do

      o "Array of codes to Cascade if status is included",
        :cascade, false

      o "The directories this application resides in",
        :root, File.dirname($0)

      o "The directories containing static files to be served",
        :publics, 'publics'

      o "Directories containing the view templates",
        :views, 'views'

      o "Directories containing the layout templates",
        :layouts, 'layouts'

    end

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
