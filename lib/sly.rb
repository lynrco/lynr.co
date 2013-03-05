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

    def self.setup(opts={})
      options.merge! opts
    end

    def initialize(app, opts={})
      @app = app
      Sly::App.setup opts
    end

    def call(env)
      res = Sly::DynaMap.call(env)
      # Behave like a cascade
      # TODO: Make cascade behavior an option
      if (Sly::App.options.cascade && Sly::App.options.cascade.include?(res[0].to_i))
        @app.call(env)
      else
        res
      end
    end

  end

end
