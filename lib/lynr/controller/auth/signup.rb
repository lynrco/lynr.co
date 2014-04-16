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

    # ## `Auth::Signup#before_each(req)`
    #
    # Set attributes used in all methods.
    #
    def before_each(req)
      super
      @subsection = "signup"
      @title = "Sign Up for Lynr"
      @stripe_pub_key = stripe_config.pub_key
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
      render 'auth/signup.erb' if has_errors?
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

    # ## `Auth::Signup#get_signup(req)`
    #
    # Render signup page for `req`.
    #
    def get_signup(req)
      render 'auth/signup.erb'
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

    # ## `Auth::Signup#post_signup(req)`
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
      dealer = create_dealership(identity, customer)
      Lynr::Events.emit(type: 'dealership.created', data: {
        dealership_id: dealer.id.to_s,
        cookies: req.cookies,
      })
      # Create and Save dealership
      req.session['dealer_id'] = dealer.id
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

    # ## `Auth::Signup#stripe_config`
    #
    # Get the stripe configuration.
    #
    def stripe_config
      Lynr.config('app').stripe
    end

    # ## `Auth::Signup#validate_signup(posted)`
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

end
