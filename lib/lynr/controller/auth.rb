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

    get  '/signup',         :get_signup
    post '/signup',         :post_signup
    get  '/signin',         :get_signin
    post '/signin',         :post_signin
    get  '/signin/:token',  :get_token_signin
    get  '/signout',        :get_signout

    def before_GET(req)
       send_to_admin(req) if ['/signin', '/signup'].include?(req.path) && req.session['dealer_id']
    end

    # ## Sign Up Handlers
    def get_signup(req)
      @subsection = "signup"
      @title = "Sign Up for Lynr"
      @stripe_pub_key = Lynr::Web.config['stripe']['pub_key']
      render 'auth/signup.erb'
    end

    def post_signup(req)
      @subsection = "signup submitted"
      @title = "Sign Up for Lynr"
      @errors = validate_signup(@posted)
      @stripe_pub_key = Lynr::Web.config['stripe']['pub_key']
      return render 'auth/signup.erb' if has_errors?
      # Create account
      identity = Lynr::Model::Identity.new(@posted['email'], @posted['password'])
      # Create Customer and subscribe them
      customer = Stripe::Customer.create(
        card: @posted['stripeToken'],
        plan: Lynr::Web.config['stripe']['plan'],
        email: identity.email
      )
      # Create and Save dealership
      dealer = dealer_dao.save(Lynr::Model::Dealership.new({
        'identity' => identity,
        'customer_id' => customer.id
      }))
      req.session['dealer_id'] = dealer.id
      # Send to admin pages?
      redirect "/admin/#{dealer.id.to_s}"
    rescue Stripe::CardError => sce
      handle_stripe_error!(sce, sce.message)
    rescue Stripe::InvalidRequestError => sire
      handle_stripe_error!(sire, "You might have submitted the form more than once.")
    rescue Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => sse
      msg = "Couldn't communicate with our card processor. We've been notified of the error."
      handle_stripe_error!(sse, msg)
    end

    # ## `Lynr::Controller::Auth#handle_stripe_error!`
    #
    # This method takes an error and message and maps it to the credit card
    # fields and then provides an appropriate response object. The 'bang' at
    # the end of the method name signifies it terminates a request.
    #
    # ### Params
    #
    # * `err` is a Exception or Error class, it could be any kind of object
    #   but it is logged as a warning.
    # * `message` is the error message displayed to the potential customer
    #   informing them of the problem. This message is tied to the credit card
    #   info.
    #
    # ### Returns
    #
    # A `Rack::Response` style object that responds to a `finish` message.
    #
    def handle_stripe_error!(err, message)
      log.warn { err }
      @errors['stripeToken'] = message
      @posted.delete('stripeToken')
      render 'auth/signup.erb'
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
      redirect "/admin/#{dealership.id.to_s}"
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

    def send_to_admin(req)
      redirect "/admin/#{req.session['dealer_id']}"
    end

    # ## Validation Helpers

    def validate_signup(posted)
      errors = validate_required(posted, ['email', 'password'])
      email = posted['email']
      password = posted['password']

      errors['email'] ||= error_for_email(dealer_dao, email)
      errors['password'] ||= error_for_passwords(password, posted['password_confirm'])

      if (posted['agree_terms'].nil?)
        errors['agree_terms'] = "You must agree to Terms &amp; Conditions."
      end

      if (posted['stripeToken'].nil? || posted['stripeToken'].empty?)
        errors['stripeToken'] = "Your card wasn't accepted."
      end

      errors.delete_if { |k,v| v.nil? }
    end

    def validate_signin(posted)
      errors = validate_required(posted, ['email', 'password'])
      email = posted['email']
      password = posted['password']
      dealership = dealer_dao.get_by_email(email)

      if (errors.empty? && (dealership.nil? || !dealership.identity.auth?(email, password)))
        errors['account'] = "Invalid email or password."
      end

      errors
    end

  end

end; end;
