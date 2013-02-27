require 'bundler/setup'
require 'ramaze'

require './lib/lynr/logging'
require './lib/lynr/controller/root'

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
      Ramaze.options.views = ['views']
    end

    def self.instance
      @app = Lynr::App.new if !@app
      @app
    end

  end

end
