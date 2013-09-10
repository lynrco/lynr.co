require 'bundler/setup'
require 'ramaze'
require 'sly'
require 'stripe'

require 'lynr'
require 'lynr/config'
require 'lynr/controller/root'
require 'lynr/controller/admin'
require 'lynr/controller/admin/account'
require 'lynr/controller/admin/billing'
require 'lynr/controller/admin/manage_vehicles'
require 'lynr/controller/admin/vehicle'
require 'lynr/controller/api'
require 'lynr/controller/auth'
require 'lynr/logging'

module Lynr

  class Web

    include Lynr::Logging

    @app = false

    attr_reader :config

    def initialize
      @config = Lynr::Config.new('app', ENV['whereami'])
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

    def self.instance
      @app = Lynr::Web.new if !@app
      @app
    end

    def self.config
      instance.config
    end

  end

end
