require 'bundler/setup'
require 'ramaze'

require './lib/lynr/logging'
require './lib/lynr/controller/root'
require './lib/lynr/controller/admin'

require './lib/sly'
require './lib/lynr/controller/test'

module Lynr

  class App

    include Lynr::Logging

    @app = false
    API_ROOT = '/api'
    API_VERSION = 'v1'
    API_BASE = "#{API_ROOT}/#{API_VERSION}"

    VERSION = '0.0.1'

    def self.setup
      Ramaze.options.roots = [__DIR__]
      # What if views is set from configuration file?
      # There could be a different 'app' running for each type or at least
      # for the mobile site.
      #
      # Each controller can set options specific to itself but only at startup.
      # Can I add specific controller instances with options set? Options don't
      # seem to be set in `#initialize` method invocations.
      Ramaze.options.views = ['views']
    end

    def self.instance
      @app = Lynr::App.new if !@app
      @app
    end

  end

end
