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
require './lib/lynr/controller/admin/vehicle/add'
require './lib/lynr/controller/admin/vehicle/delete'
require './lib/lynr/controller/admin/vehicle/edit'
require './lib/lynr/controller/admin/vehicle/photos'
require './lib/lynr/controller/admin/vehicle/view'
require './lib/lynr/controller/admin/vin'
require './lib/lynr/controller/api'
require './lib/lynr/controller/auth'
require './lib/lynr/controller/auth/ebay'
require './lib/lynr/controller/auth/ebay/callback'
require './lib/lynr/controller/auth/ebay/failure'
require './lib/lynr/logging'
require './lib/lynr/view/renderer'

module Lynr

  # # `Lynr::Web`
  #
  # Collection of helper methods to access configuration and logging for Lynr
  # application.
  #
  class Web

    include Lynr::Logging

    @app = false

    attr_reader :config

    # ## `Lynr::Web.new`
    #
    # Create a new instance with `Lynr::Config` for 'app' based on `ENV['whereami'].
    #
    def initialize
      @config = Lynr.config('app')
    end

    # ## `Lynr::Web.config`
    #
    # Helper method to get to app config
    #
    def self.config
      instance.config
    end

    # ## `Lynr::Web.instance`
    #
    # Helper method to get at `Lynr::Web` singleton instance.
    #
    def self.instance
      @app = Lynr::Web.new if !@app
      @app
    end

    # ## `Lynr::Web.render(template, options)`
    #
    # Create a `Rack::Response` from `template` and `options`
    #
    def self.render(template, options={})
      opts = { headers: Lynr.config('app').headers.to_hash, }.merge(options)
      Lynr::View::Renderer.new(template, opts).render
    end

    # ## `Lynr::Web.setup`
    #
    # Helper method to set up application wide variables.
    #
    def self.setup
      Stripe.api_key = instance.config['stripe']['key']
      Stripe.api_version = instance.config['stripe']['version'] || '2013-02-13'
    end

    # ## `Lynr::Web#call(env)`
    #
    # Process Rack `env` to get a `Rack::Response`
    #
    def call(env)
      Sly.core.call(env)
    rescue Sly::TooManyRoutesError
      Sly::Router::TooMany
    rescue Sly::NotFoundError
      Web.render 'fourohfour.erb', status: 404, title: 'Not Found'
    rescue Sly::HttpError => err
      Web.render 'fivehundy.erb', status: err.status, title: err.status
    end

  end

end
