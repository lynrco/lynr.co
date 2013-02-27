require 'bundler/setup'
require 'ramaze'

require './lib/lynr/logging'
require './lib/lynr/controller/root'

module Lynr

  class App

    include Lynr::Logging

    @app = false
    ROOT = '/api'
    VERSION = 'v1'
    BASE = "#{ROOT}/#{VERSION}"

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
