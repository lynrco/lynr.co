require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/model/token'
require './lib/lynr/persist/dao'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator'

module Lynr; module Controller;

  # # `Lynr::Controller::Auth`
  #
  # Controller for the authorization actions like creating an account or
  # signing into an existing account.
  #
  class Auth < Lynr::Controller::Base

    include Lynr::Validator::Email
    include Lynr::Validator::Helpers
    include Lynr::Validator::Password

    # Provides `error_class`, `error_message`, `has_error?`, `has_errors?`,
    # `posted`, `card_data`
    include Lynr::Controller::FormHelpers

    attr_reader :dealer_dao

    # ## `Lynr::Controller::Auth.new`
    #
    # Create a new Auth controller with default information like headers and
    # section information.
    #
    def initialize
      super
      @section = "auth"
      @dealer_dao = Lynr::Persist::DealershipDao.new
    end

    get  '/signin',         :get_signin
    post '/signin',         :post_signin
    get  '/signin/:token',  :get_token_signin
    get  '/signout',        :get_signout

    def before_GET(req)
       send_to_admin(req) if ['/signin', '/signup'].include?(req.path) && req.session['dealer_id']
    end

    # ## Sign In Handlers
    def get_signin(req)
      @subsection = "signin"
      @title = "Sign In to Lynr"
      render 'auth/signin.erb'
    end

    def post_signin(req)
      @subsection = "signup submitted"
      @title = "Sign In to Lynr"
      @errors = validate_signin(@posted)
      return render 'auth/signin.erb' if has_errors?
      dealership = dealer_dao.get_by_email(@posted['email'])
      # Send to admin pages
      req.session['dealer_id'] = dealership.id
      send_to_admin(req, dealership)
    end

    def get_token_signin(req)
      id = BSON::ObjectId.from_string(req['token'])
      dao = Lynr::Persist::Dao.new
      token = dao.read(id)
      return unauthorized if token.nil? or token.expired?
      dao.delete(id)
      req.session['dealer_id'] = token.dealership
      redirect "/admin/#{token.dealership.to_s}/account/password"
    end

    # ## Sign Out Handler
    def get_signout(req)
      req.session.destroy
      redirect '/'
    end

    # ## Redirect Helpers

    def send_to_admin(req, dealership=nil)
      dealership = dealer_dao.get(req.session['dealer_id']) if dealership.nil?
      redirect "/admin/#{dealership.slug}"
    end

    # ## Validation Helpers

    def validate_signin(posted)
      errors = validate_required(posted, ['email', 'password'])
      email = posted['email']
      password = posted['password']
      dealership = dealer_dao.get_by_email(email)

      if (errors.empty? && (dealership.nil? || !dealership.identity.auth?(email, password)))
        errors['account'] = "Invalid email or password."
      end

      errors.delete_if { |k,v| v.nil? }
    end

  end

end; end;

require './lib/lynr/controller/auth/forgot'
require './lib/lynr/controller/auth/signup'
