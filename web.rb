require 'bundler/setup'
require 'ramaze'
require 'stripe'

require './lib/sly'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/controller/root'
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
      Ramaze.options.roots = [__DIR__]
      # What if views is set from configuration file?
      # There could be a different 'app' running for each type or at least
      # for the mobile site.
      #
      # Each controller can set options specific to itself but only at startup.
      # Can I add specific controller instances with options set? Options don't
      # seem to be set in `#initialize` method invocations.
      Ramaze.options.views = ['views']

      Sly::App.options.layouts = 'layout'

      Stripe.api_key = instance.config['stripe']['key']
      Stripe.api_version = instance.config['stripe']['version'] || '2013-02-13'
    end

  end

end
