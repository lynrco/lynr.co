require 'json'
require 'openssl'

require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/converter/number_translator'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/persist/vehicle_dao'
require './lib/lynr/validator/helpers'
require './lib/lynr/view/menu'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Lynr::Controller::Base

    # Provides `error_for_slug`, `is_valid_slug?`, `validate_required`
    include Lynr::Validator::Helpers
    # Provides `error_class`, `error_message`, `errors`, `has_error?`,
    # `has_errors?`, `posted`, `card_data`
    include Lynr::Controller::FormHelpers

    attr_reader :vehicle_dao

    get  '/admin/:slug', :index
    get  '/menu/:slug',  :menu

    def initialize
      super
      @section = "admin"
      @vehicle_dao = Lynr::Persist::VehicleDao.new
      @dealership = false
    end

    # ## `Admin#before_each(req)`
    #
    # Make sure dealership is authorized to view the admin page and the
    # dealership associated with `:slug` exists.
    #
    # NOTE: `super` is called at the end of this method in order to ensure
    # `Rack::Response` instances returned by child implementations of
    # `before_METHOD` methods are returned to user agent.
    #
    def before_each(req)
      return unauthorized unless authorized?(req)
      return not_found unless dealership(req)
      @dealership = dealership(req)
      super
    end

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Renders `views/admin/index.erb`.
    #
    def index(req)
      @subsection = 'vehicle-list'
      @vehicles = vehicle_dao.list(@dealership)
      @title = "Welcome back #{@dealership.name}"
      req.session.delete('back_uri')
      render 'admin/index.erb'
    end

    # ## `Admin#menu(req)`
    #
    # Primarmy menu shown over the admin homepage.
    #
    def menu(req)
      @menu_vis = 'menu-visible-primary'
      index(req)
    end

    # ## Helpers

    # ## `Admin::Vehicle#dealership(req)`
    #
    # Get dealership object out of `req`.
    #
    def dealership(req)
      return @dealership unless @dealership == false
      if BSON::ObjectId.legal?(req['slug'])
        @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      else
        @dealership = dealer_dao.get_by_slug(req['slug'])
      end
    end

    # ## Menus

    # ## `Admin#menu_primary`
    #
    # Overrides `Lynr::Controller::Base#menu_primary` to return a menu for the dealership.
    #
    def menu_primary
      Lynr::View::Menu.new('Menu', "/menu/#{@dealership.slug}", :menu_admin) unless @dealership.nil?
    end

    # ## `Lynr::Controller::Admin#authorized?`
    #
    # Whether or not the current user is authorized to access the requested dealership
    #
    # ### Params
    #
    # * `req` Request with session and dealership information to be compared
    #
    # ### Returns
    #
    # true if current user is allowed to view/modify the requested Dealership
    # false otherwise
    #
    def authorized?(req)
      req.session['dealer_id'] == dealership(req).id
    end

    # TODO: Write documentation for `#transloadit_params`
    def transloadit_params(template_id_name)
      transloadit = Lynr::Web.config['transloadit']
      expires = (Time.now + (60 * 10)).utc.strftime('%Y/%m/%d %H:%M:%S+00:00')
      params = {
        auth: { expires: expires, key: transloadit['auth_key'] },
        template_id: transloadit[template_id_name]
      }
    end

    # TODO: Write documentation for `#transloadit_params_signature`
    def transloadit_params_signature(params)
      auth_secret = Lynr::Web.config['transloadit']['auth_secret']
      return nil if auth_secret.nil?
      digest = OpenSSL::Digest::Digest.new('sha1')
      OpenSSL::HMAC.hexdigest(digest, auth_secret, JSON.generate(params))
    end

  end

end; end;
