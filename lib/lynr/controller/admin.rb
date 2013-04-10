require 'sly'
require 'lynr/controller/base'
require 'lynr/persist/dealership_dao'
require 'lynr/persist/vehicle_dao'
require 'lynr/validator/helpers'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Lynr::Controller::Base

    attr_reader :dealer_dao, :vehicle_dao

    def initialize
      super
      @section = "admin"
      @dealer_dao = Lynr::Persist::DealershipDao.new
      @vehicle_dao = Lynr::Persist::VehicleDao.new
    end

    get '/admin/:slug/account', :get_account
    get '/admin/:slug', :index

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Renders `views/admin/index.erb`.
    #
    def index(req)
      @subsection = 'list'
      id = BSON::ObjectId.from_string(req['slug'])
      @dealership = dealer_dao.get(id)
      return not_found if @dealership.nil?
      @vehicles = vehicle_dao.list(@dealership)
      @title = "Welcome back #{@dealership.name}"
      @owner = @dealership.name
      render 'admin/index.erb'
    end

    def get_account(req)
      @subsection = 'account'
      return not_found if !authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      render 'admin/account.erb'
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

  end

end; end;
