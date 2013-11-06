require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/persist/vehicle_dao'
require './lib/lynr/validator/helpers'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Lynr::Controller::Base

    # Provides `is_valid_email?`, `is_valid_password?`, `validate_required`
    include Lynr::Validator::Helpers
    # Provides `error_class`, `error_message`, `has_error?`, `has_errors?`,
    # `posted`, `card_data`
    include Lynr::Controller::FormHelpers

    attr_reader :dealer_dao, :vehicle_dao

    def initialize
      super
      @section = "admin"
      @dealer_dao = Lynr::Persist::DealershipDao.new
      @vehicle_dao = Lynr::Persist::VehicleDao.new
    end

    get  '/admin/:slug', :index
    get  '/menu/:slug',  :menu

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Renders `views/admin/index.erb`.
    #
    def index(req)
      @subsection = 'vehicle-list'
      id = BSON::ObjectId.from_string(req['slug'])
      @dealership = dealer_dao.get(id)
      return not_found if @dealership.nil?
      @vehicles = vehicle_dao.list(@dealership)
      @title = "Welcome back #{@dealership.name}"
      @owner = @dealership.name
      render 'admin/index.erb'
    end

    def menu(req)
      @menu_vis = 'menu-visible-primary'
      index(req)
    end

    # ## Helpers

    # ## `Lynr::Controller::Admin#session_user`
    #
    # Gets the current user out of the session and returns it
    #
    # ### Params
    #
    # * `req` Request with access to session out of which to get the user
    #
    # ### Returns
    #
    # Currently logged in instance of `Lyrn::Model::Dealership`
    #
    def session_user(req)
      id = req.session['dealer_id']
      dealer_dao.get(id)
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
      req.session['dealer_id'] == BSON::ObjectId.from_string(req['slug'])
    end

    protected

    def transloadit_params(template_id_name)
      {
        auth: { key: Lynr::Web.config['transloadit']['auth_key'] },
        template_id: Lynr::Web.config['transloadit'][template_id_name]
      }
    end

  end

end; end;
