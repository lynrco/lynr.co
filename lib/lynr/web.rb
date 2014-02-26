require 'bundler/setup'
require 'librato/metrics'
require 'stripe'

require './lib/sly'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/controller/home'
require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/account'
require './lib/lynr/controller/admin/account/password'
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

    # ## `Lynr::Web#call(env)`
    #
    # Process Rack `env` to get a `Rack::Response`
    #
    def call(env)
      Sly.core.call(env)
    rescue Sly::TooManyRoutesError
      Sly::Router::TooMany
    rescue Sly::HttpError => err
      Web.render_error(err, err.status)
    rescue StandardError => se
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('error/internal', {
        to: 'tech@lynr.co',
        subject: "[#{env['HTTP_HOST']}] #{se.class} on #{env['PATH_INFO']}",
        err: se,
        req: env.dup.delete_if { |k, v| k.start_with?('rack.') }
      })) unless Lynr.env == 'development'
      Web.render_error(se)
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

    # ## `Lynr::Web.message_for_code(status)`
    #
    # Get the message display on page with HTTP `status` code.
    #
    def self.message_for_code(status)
      case status
      when 403 then "You don't have permission to view this."
      when 404 then "Why don't you try that again."
      else "We aren't sure what happend but have been notified and will look into it."
      end
    end

    # ## `Lynr::Web.render(template, options)`
    #
    # Create a `Rack::Response` from `template` and `options`
    #
    def self.render(template, options={})
      opts = { headers: Lynr.config('app').headers.to_hash, }.merge(options)
      Lynr::View::Renderer.new(template, opts).render
    end

    # ## `Lynr::Web.render_error(error, status)`
    #
    # Renders an HTTP error page for the given `status`. `status` is optional and
    # defaults to 500.
    #
    def self.render_error(error, status=500)
      Web.render 'httperror.erb', {
        error: (Lynr.env == 'development' && error),
        status: status,
        title: title_for_code(status),
        message: message_for_code(status)
      }
    end

    # ## `Lynr::Web.setup`
    #
    # Helper method to set up application wide variables.
    #
    def self.setup
      conf = instance.config

      Stripe.api_key = conf['stripe']['key']
      Stripe.api_version = conf['stripe']['version'] || '2013-02-13'

      ENV['LIBRATO_USER'] ||= conf.librato.user
      ENV['LIBRATO_TOKEN'] ||= conf.librato.token
      Librato::Metrics.authenticate conf.librato.user, conf.librato.token
    end

    # ## `Lynr::Web.title_for_code(status)`
    #
    # Get the page title to use with HTTP `status` code.
    #
    def self.title_for_code(status)
      case status
      when 403 then "Unauthorized"
      when 404 then "Not Found"
      else "Wrecked"
      end
    end

  end

end
