require './lib/lynr/controller'
require './lib/lynr/controller/auth'
require './lib/lynr/events'
require './lib/lynr/model/dealership'
require './lib/lynr/model/identity'
require './lib/lynr/model/subscription'

module Lynr::Controller

  # # `Lynr::Controller::Auth::Signup`
  #
  # Class to encapsulate the logic of displaying the singup page as well as
  # creating new accounts for Lynr.
  #
  class Auth::Signup < Lynr::Controller::Auth

    get  '/signup',         :get_signup
    post '/signup',         :post_signup

    # ## `Auth::Signup.new`
    #
    # Create a new controller instance to allow for account creation.
    #
    # NOTE: The behavior of the `Signup` varies based on the 'demo'
    # feature flag. When a new `Signup` instance is created either the
    # `Signup::Default` or `Signup::Demo` modules are used to extend the
    # controller. These modules provide the `#get_signup` and `#post_signup`
    # methods through which requests are routed in order to generate HTTP
    # responses.
    #
    def initialize
      super
      if Lynr.features.demo?
        self.send(:extend, Signup::Demo)
      else
        self.send(:extend, Signup::Default)
      end
    end

    # ## `Auth::Signup#before_each(req)`
    #
    # Set attributes used in all methods.
    #
    def before_each(req)
      @subsection = "signup"
      @title = "Sign Up for Lynr"
      @stripe_pub_key = stripe_config.pub_key
      super
    end

    # ## `Auth::Signup#before_GET(req)`
    #
    # Redirect to the admin page if there is already a dealer_id in the
    # session.
    #
    def before_GET(req)
      super
      send_to_admin(req) if req.session['dealer_id']
    end

    # ## `Auth::Signup#before_POST(req)`
    #
    # Validate data in `req` and render the page if there are errors.
    #
    def before_POST(req)
      super
      @errors = validate_signup(@posted)
      get_signup(req) if has_errors?
    end

    # ## `Auth::Signup#create_dealership(identity, customer)`
    #
    # Use `identity` and `customer` to create a new `Lynr::Model::Dealership`
    # instance and save it to the database.
    #
    def create_dealership(identity, customer)
      customer_id = if customer.nil? then nil else customer.id end
      dealership = Lynr::Model::Dealership.new({
        'identity' => identity,
        'customer_id' => customer_id,
        'subscription' => Lynr::Model::Subscription.new(plan: stripe_config.plan, status: 'trialing'),
      })
      dealer_dao.save(dealership)
    end

    # ## `Auth::Signup#handle_stripe_error!(err, message)`
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

    # ## `Auth::Signup#notify(req, dealership)`
    #
    # Store `dealership` in session for `req` and `#emit` the
    # 'dealership.created' event.
    #
    def notify(req, dealership)
      Lynr::Events.emit(type: 'dealership.created', data: {
        dealership_id: dealership.id.to_s,
        cookies: req.cookies,
      })
      req.session['dealer_id'] = dealership.id
    end

    # ## `Auth::Signup#stripe_config`
    #
    # Get the stripe configuration.
    #
    def stripe_config
      Lynr.config('app').stripe
    end

    # # `Lynr::Controller::Auth::Signup::Default`
    #
    # Method definitions to use by default. These should be a part of
    # the class definition but if they are they can not be overridden by
    # including the `Demo` module.
    #
    # NOTE: With Ruby 2.0 `Demo` module could be included via `prepend`
    # which would allow class method definitions to be overriden.
    #
    module Default

      # ## `Auth::Signup::Default#get_signup(req)`
      #
      # Render signup page for `req`.
      #
      def get_signup(req)
        render 'auth/signup.erb'
      end

      # ## `Auth::Signup::Default#post_signup(req)`
      #
      # Create a `Lynr::Model::Identity` and a `Stripe::Customer` and use them
      # to create and save a `Lynr::Model::Dealership` instance and then log
      # the new customer in.
      #
      def post_signup(req)
        # Create account
        identity = Lynr::Model::Identity.new(@posted['email'], @posted['password'])
        # Create Customer and subscribe them
        customer = Stripe::Customer.create(
          card: @posted['stripeToken'],
          plan: stripe_config.plan,
          email: identity.email
        )
        # Create and Save dealership
        dealer = create_dealership(identity, customer)
        notify(req, dealer)
        # Send to admin pages?
        send_to_admin(req, dealer)
      rescue Stripe::CardError => sce
        handle_stripe_error!(sce, sce.message)
      rescue Stripe::InvalidRequestError => sire
        handle_stripe_error!(sire, "You might have submitted the form more than once.")
      rescue Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => sse
        msg = "Couldn't communicate with our card processor. We've been notified of the error."
        handle_stripe_error!(sse, msg)
      end

      # ## `Auth::Signup::Default#validate_signup(posted)`
      #
      # Verify the validity of data in `posted` and return a `Hash` of
      # field names to error strings if there are any. Otherwise return an
      # empty `Hash`.
      #
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

    end

    # # `Lynr::Controller::Auth::Signup::Demo`
    #
    # Method definitions to use when the demo 'feature' is on.
    #
    module Demo

      # ## `Auth::Signup::Demo#get_signup(req)`
      #
      # Render signup page for `req`.
      #
      def get_signup(req)
        render 'demo/auth/signup.erb'
      end

      # ## `Auth::Signup::Demo#post_signup(req)`
      #
      # Create a `Lynr::Model::Identity` and a `Stripe::Customer` and use them
      # to create and save a `Lynr::Model::Dealership` instance and then log
      # the new customer in.
      #
      def post_signup(req)
        # Create account
        identity = Lynr::Model::Identity.new(@posted['email'], @posted['email'])
        # Create and Save dealership
        dealer = create_dealership(identity, nil)
        notify(req, dealer)
        # Send to admin pages?
        send_to_admin(req, dealer)
      end

      # ## `Auth::Signup::Demo#validate_signup(posted)`
      #
      # Verify the validity of data in `posted` and return a `Hash` of
      # field names to error strings if there are any. Otherwise return an
      # empty `Hash`.
      #
      def validate_signup(posted)
        errors = validate_required(posted, ['email'])
        email = posted['email']

        errors['email'] ||= error_for_email(dealer_dao, email)

        errors.delete_if { |k,v| v.nil? }
      end

    end


  end

end
