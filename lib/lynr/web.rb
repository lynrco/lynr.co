require 'bundler/setup'
require 'librato/metrics'
require 'stripe'

require './lib/sly'

require './lib/lynr'
require './lib/lynr/config'
require './lib/lynr/controller/admin'
require './lib/lynr/controller/admin/account'
require './lib/lynr/controller/admin/account/cancel'
require './lib/lynr/controller/admin/account/password'
require './lib/lynr/controller/admin/billing'
require './lib/lynr/controller/admin/inventory'
require './lib/lynr/controller/admin/manage_vehicles'
require './lib/lynr/controller/admin/search'
require './lib/lynr/controller/admin/support'
require './lib/lynr/controller/admin/vehicle/add'
require './lib/lynr/controller/admin/vehicle/delete'
require './lib/lynr/controller/admin/vehicle/edit'
require './lib/lynr/controller/admin/vehicle/photos'
require './lib/lynr/controller/admin/vehicle/view'
require './lib/lynr/controller/admin/vin'
require './lib/lynr/controller/api'
require './lib/lynr/controller/auth'
require './lib/lynr/controller/auth/ebay'
# Email controller is for email previews
require './lib/lynr/controller/email' if Lynr.env == 'development'
require './lib/lynr/controller/home'
require './lib/lynr/controller/js_identity'
require './lib/lynr/controller/legal'
require './lib/lynr/controller/ping'
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

      Web.setup_stripe(config)
      Web.setup_librato(config) if Lynr.metrics.configured?
    end

    # ## `Lynr::Web#call(env)`
    #
    # Process Rack `env` to get a `Rack::Response`
    #
    def call(env)
      Sly.core.call(env)
    rescue Sly::TooManyRoutesError
      Sly::Router::TooMany
    rescue Sly::UnauthorizedError
      log.warn('type=httperror code=403 msg=redirecting to signin')
      Rack::Response.new.tap do |res|
        res.redirect "/signin?next=#{URI.encode(env['PATH_INFO'])}"
      end
    rescue Sly::HttpError => err
      Web.render_error(err, err.status)
    rescue StandardError => se
      Lynr.producer('job').publish(Lynr::Queue::EmailJob.new('error/internal', {
        to: 'tech@lynr.co',
        subject: "[#{env['HTTP_HOST']}] #{se.class} on #{env['PATH_INFO']}",
        err: se,
        req: env.dup.delete_if { |k, v| k.start_with?('rack.') }
      })) unless Lynr.env == 'development'
      Web.render_error(se)
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

    # ## `Lynr::Web.setup_librato(conf)`
    #
    # Set LIBRATO_* environment variables if they aren't set as actual
    # environment variables.
    #
    def self.setup_librato(conf)
      ENV['LIBRATO_USER'] ||= conf.librato.user
      ENV['LIBRATO_TOKEN'] ||= conf.librato.token
      ENV['LIBRATO_SOURCE'] ||= conf.librato.source
      Librato::Metrics.authenticate conf.librato.user, conf.librato.token
    end

    # ## `Lynr::Web.setup_stripe(conf)`
    #
    # Helper method to set up Stripe application variables.
    #
    def self.setup_stripe(conf)
      Stripe.api_key = conf['stripe']['key']
      Stripe.api_version = conf['stripe']['version'] || '2013-02-13'
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
