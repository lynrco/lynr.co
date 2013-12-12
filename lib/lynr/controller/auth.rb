require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator/helpers'

module Lynr; module Controller;

  # # `Lynr::Controller::Auth`
  #
  # Controller for the authorization actions like creating an account or
  # signing into an existing account.
  #
  class Auth < Lynr::Controller::Base

    # Provides `is_valid_email?`, `is_valid_password?`, `validate_required`
    include Lynr::Validator::Helpers
    # Provides `error_class`, `error_message`, `has_error?`, `has_errors?`,
    # `posted`, `card_data`
    include Lynr::Controller::FormHelpers

    attr_reader :dao

    # ## `Lynr::Controller::Auth.new`
    #
    # Create a new Auth controller with default information like headers and
    # section information.
    #
    def initialize
      super
      @section = "auth"
      @dao = Lynr::Persist::DealershipDao.new
    end

    get  '/signup',  :get_signup
    post '/signup',  :post_signup
    get  '/signin',  :get_signin
    post '/signin',  :post_signin
    get  '/signout', :get_signout

    def before_GET(req)
      redirect "/admin/#{req.session['dealer_id']}" if ['/signin', '/signup'].include?(req.path) && req.session['dealer_id']
    end

    # ## Sign Up Handlers
    def get_signup(req)
      @subsection = "signup"
      @title = "Sign Up for Lynr"
      render 'auth/signup.erb'
    end

    def post_signup(req)
      @subsection = "signup submitted"
      @title = "Sign Up for Lynr"
      @posted = req.POST
      @errors = validate_signup(@posted)
      return render 'auth/signup.erb' if has_errors?
      # Create account
      identity = Lynr::Model::Identity.new(@posted['email'], @posted['password'])
      # Create Customer and subscribe them
      customer = Stripe::Customer.create(
        card: @posted['stripeToken'],
        plan: 'lynr_beta',
        email: identity.email
      )
      # Create and Save dealership
      dealer = dao.save(Lynr::Model::Dealership.new({
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
      @posted['stripeToken'].delete
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
      @posted = req.POST
      @errors = validate_signin(@posted)
      return render 'auth/signin.erb' if has_errors?
      dealership = dao.get_by_email(@posted['email'])
      # Send to admin pages
      req.session['dealer_id'] = dealership.id
      redirect "/admin/#{dealership.id.to_s}"
    end

    # ## Sign Out Handler
    def get_signout(req)
      req.session.destroy
      redirect '/'
    end

    # ## Validation Helpers
    def validate_signup(posted)
      errors = validate_required(posted, ['email', 'password'])
      email = posted['email']
      password = posted['password']

      if (errors['email'].nil?)
        if (!is_valid_email?(email))
          errors['email'] = "Check your email address."
        elsif (dao.account_exists?(email))
          errors['email'] = "#{email} is already taken."
        end
      end
      if (errors['password'].nil?)
        if (!is_valid_password?(password))
          errors['password'] = "Your password is too short."
        elsif (password != posted['password_confirm'])
          errors['password'] = "Your passwords don't match."
        end
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
      email = posted['email']
      password = posted['password']
      dealership = dao.get_by_email(email)

      if (errors.empty? && (dealership.nil? || !dealership.identity.auth?(email, password)))
        errors['account'] = "Invalid email or password."
      end

      errors
    end

  end

end; end;
