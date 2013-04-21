require 'sly'
require 'lynr/controller/base'
require 'lynr/controller/form_helpers'
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

    # Provides `is_valid_email?`, `is_valid_password?`, `validate_required`
    include Lynr::Validator::Helpers
    # Provides `error_class`, `error_message`, `has_error`, `posted`
    include Lynr::Controller::FormHelpers

    attr_reader :dealer_dao, :vehicle_dao

    def initialize
      super
      @section = "admin"
      @dealer_dao = Lynr::Persist::DealershipDao.new
      @vehicle_dao = Lynr::Persist::VehicleDao.new
    end

    get  '/admin/:slug', :index
    get  '/admin/:slug/account', :get_account
    post '/admin/:slug/account', :post_account

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
      return unauthorized unless authorized?(req)
      @subsection = 'account'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @title = "Account Information"
      render 'admin/account.erb'
    end

    def post_account(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST
      @errors = validate_account_info
      # TODO: These updates should be scheduled, they aren't critical
      if email_changed? || name_changed?
        customer = Stripe::Customer.retrieve(@dealership.customer_id)
        customer.description = posted['name'] if name_changed?
        customer.email = posted['email'] if email_changed?
        customer.save
      end
      # TODO: Trigger an email warning about email change
      if email_changed?
        @posted['identity'] = Lynr::Model::Identity.new(posted['email'], @dealership.identity.password)
      end
      @dealership = dealer_dao.save(@dealership.set(posted))
      redirect "/admin/#{@dealership.id.to_s}/account"
    end

    def email_changed?
      @dealership.identity.email != posted['email']
    end

    def name_changed?
      @dealership.name != posted['name']
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

    def validate_account_info
      errors = validate_required(posted, ['email'])
      email = posted['email']

      if (errors['email'].nil?)
        if (!is_valid_email?(email))
          errors['email'] = "Check your email address."
        elsif (email != @dealership.identity.email && dealer_dao.account_exists?(email))
          errors['email'] = "#{email} is already taken."
        end
      end

      errors
    end

  end

end; end;
