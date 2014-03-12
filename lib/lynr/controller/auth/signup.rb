module Lynr::Controller

  class Auth::Signup < Lynr::Controller::Auth

    get  '/signup',         :get_signup
    post '/signup',         :post_signup

    def before_each(req)
      super
      @subsection = "signup"
      @title = "Sign Up for Lynr"
      @stripe_pub_key = stripe_config.pub_key
    end

    def before_GET(req)
      super
      send_to_admin(req) if req.session['dealer_id']
    end

    def before_POST(req)
      super
      @errors = validate_signup(@posted)
      render 'auth/signup.erb' if has_errors?
    end

    def create_dealership(identity, customer)
      dealership = Lynr::Model::Dealership.new({
        'identity' => identity,
        'customer_id' => customer.id
      })
      dealer_dao.save(dealership)
    end

    def get_signup(req)
      render 'auth/signup.erb'
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

    def stripe_config
      Lynr.config('app').stripe
    end

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
