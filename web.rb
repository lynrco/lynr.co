require 'bundler/setup'
require 'stripe'

require './lib/sly'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/controller/home'
require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/account'
require './lib/lynr/controller/admin/billing'
require './lib/lynr/controller/admin/manage_vehicles'
require './lib/lynr/controller/admin/vehicle'
require './lib/lynr/controller/admin/vin'
require './lib/lynr/controller/api'
require './lib/lynr/controller/auth'
require './lib/lynr/logging'

module Lynr

  class Web

    include Lynr::Logging

    ROOT = File.expand_path(File.dirname(__FILE__))

    @app = false

    attr_reader :config

    def initialize
      @config = Lynr.config('app')
    end

    def self.config
      instance.config
    end

    def self.instance
      @app = Lynr::Web.new if !@app
      @app
    end

    def self.setup
      Sly::App.setup root: ROOT, cascade: false, layouts: 'layout'

      Stripe.api_key = instance.config['stripe']['key']
      Stripe.api_version = instance.config['stripe']['version'] || '2013-02-13'
    end

  end

end
