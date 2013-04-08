require './lib/sly'
require './lib/sly/view/erb_helpers'
require './lib/lynr/validator/helpers'
require './lib/lynr/persist/dealership_dao'

module Lynr; module Controller;

  # # `Lynr::Controller::Auth`
  #
  # Controller for the authorization actions like creating an account or
  # signing into an existing account.
  #
  class Auth < Sly::Node

    include Lynr::Logging
    # Provides `is_valid_email?`
    include Lynr::Validator::Helpers
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    attr_reader :dao

    # ## `Lynr::Controller::Auth.new`
    #
    # Create a new Auth controller with default information like headers and
    # section information.
    #
    def initialize
      super
      @headers = {
        "Content-Type" => "text/html; charset=utf-8",
        "Header" => "Lynr.co Application Server"
      }
      @section = "auth"

      @dao = Lynr::Persist::DealershipDao.new
    end

    get  '/signup', :get_signup
    post '/signup', :post_signup
    get  '/signin', :get_signin
    post '/signin', :post_signin

    set_render_options({ layout: 'default_sly.erb' })

    # ## View Helper Methods

    # ## `Lynr::Controller::Auth#error_class`
    #
    # Provides an error class for a field in the markup which has an error
    # associated with the given field.
    #
    # ### Params
    # 
    # * `field` to check `@errors` for
    #
    # ### Returns
    #
    # 'fs-error' if there is an error for `field` empty string otherwise
    #
    def error_class(field)
      if has_error(field) then 'fs-error' else '' end
    end

    def error_message(field)
      if has_error(field) then @errors[field] else "" end
    end

    def has_error(field)
      !@errors.nil? && @errors.include?(field)
    end

    # ## Sign Up Handlers
    def get_signup(req)
      @subsection = "signup"
      @posted = {}
      @errors = {}
      @title = "Sign Up for Lynr"
      render 'auth/signup.erb'
    end

    def post_signup(req)
      @subsection = "signup submitted"
      @posted = req.POST
      @errors = validate_signup(@posted)
      @title = "Sign Up for Lynr"
      if (@errors.empty?)
        # Create account
        identity = Lynr::Model::Identity.new(@posted['email'], @posted['password'])
        # Create Customer and subscribe them
        customer = Stripe::Customer.create(
          card: @posted['stripeToken'],
          plan: 'lynr_beta',
          email: identity.email
        )
        # Create and Save dealership
        dealership = Lynr::Model::Dealership.new({ 'identity' => identity, 'customer_id' => customer.id })
        @dealership = dao.save(dealership)
        # Send to admin pages?
        render 'auth/signed_up.erb'
      else
        render 'auth/signup.erb'
      end
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
      render 'auth/signup.erb'
    end

    # ## Sign In Handlers
    def get_signin(req)
      @subsection = "signin"
      @posted = {}
      @errors = {}
      @title = "Sign In to Lynr"
      render 'auth/signin.erb'
    end

    def post_signin(req)
      @subsection = "signup submitted"
      @posted = req.POST
      @errors = validate_signin(@posted)
      @title = "Sign In to Lynr"
      if (@errors.empty?)
        @dealership = dao.get_by_email(@posted['email'])
        # Send to admin pages
        render 'auth/signed_up.erb'
      else
        render 'auth/signin.erb'
      end
    end

    # ## Validation Helpers
    def validate_signup(posted)
      errors = validate_required(posted, ['email', 'password'])

      if (errors['email'].nil? && !is_valid_email?(posted['email']))
        errors['email'] = "Check your email address."
      elsif (errors['email'].nil? && dao.account_exists?(posted['email']))
        errors['email'] = "#{posted['email']} is already taken."
      end
      if (errors['password'].nil? && !is_valid_password?(posted['password']))
        errors['password'] = "Your password is too short."
      end
      if (posted['password'] != posted['password_confirm'])
        errors['password'] = "Your passwords don't match."
      end
      if (posted['agree_terms'].nil?)
        errors['agree_terms'] = "You must agree to Terms &amp; Conditions."
      end
      if (posted['stripeToken'].nil? || posted['stripeToken'].empty?)
        errors['stripeToken'] = "Your card wasn't accepted."
      end

      errors
    end

    def validate_signin(posted)
      errors = validate_required(posted, ['email', 'password'])
      dealership = dao.get_by_email(posted['email'])
      if (errors.empty? && (dealership.nil? || dealership.identity != @posted))
        errors['account'] = "Invalid email or password."
      end

      errors
    end

    def validate_required(posted, fields)
      errors = {}
      fields.each do |key|
        if (!(posted.include?(key) && posted[key].length > 0))
          errors[key] = "#{key.capitalize} is required."
        end
      end

      errors
    end

  end

end; end;
