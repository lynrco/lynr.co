require './lib/lynr/controller/admin'

module Lynr; module Controller;

  # # `Lynr::Controller::AdminBilling`
  #
  # Handles requests for the billing information page.
  #
  class AdminBilling < Lynr::Controller::Admin

    get  '/admin/:slug/billing', :get_billing
    post '/admin/:slug/billing', :post_billing

    # ## `AdminBilling.new`
    #
    # Create a new instance of this controller and set up instance properties
    # needed for all request handlers.
    #
    def initialize
      super
      @title = "Billing Information"
      @stripe_pub_key = Lynr::Web.config['stripe']['pub_key']
      @subsection = 'billing'
    end

    # ## `AdminBilling#before_POST(req)`
    #
    # Do data validation before processing a POST request. It doesn't need to be
    # in the POST handler.
    #
    def before_POST(req)
      super
      @errors = validate_billing_info
      render 'admin/billing.erb' if has_errors?
    end

    # ## `AdminBilling#get_account(req)`
    #
    # Handle GET request for the billing information page.
    #
    def get_billing(req)
      @msg = req.session.delete('billing_flash_msg')
      # TODO: This card information could be stored locally. It is innocuous enough.
      # Or perhaps in memcache or something
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      @card = customer.active_card
      render 'admin/billing.erb'
    end

    # ## `AdminBilling#post_account(req)`
    #
    # Handle POST request for the billing information page by inflating objects and
    # updating data.
    #
    def post_billing(req)
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      customer.card = posted['stripeToken']
      customer.save
      req.session['billing_flash_msg'] = "Card updated successfully."
      redirect "/admin/#{@dealership.slug}/billing"
    rescue Stripe::CardError => sce
      handle_stripe_error!(sce, sce.message)
    rescue Stripe::InvalidRequestError => sire
      handle_stripe_error!(sire, "You might have submitted the form more than once.")
    rescue Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => sse
      msg = "Couldn't communicate with our card processor. We've been notified of the error."
      handle_stripe_error!(sse, msg)
    end

    # ## `Lynr::Controller::AdminBilling#handle_stripe_error!`
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
      render 'admin/billing.erb'
    end

    # ## `AdminBilling#validate_billing_info`
    #
    # *Protected* Check `posted` data in the request is valid. Returns a `Hash`
    # with error information. `Hash` is empty if no errors, otherwise key value
    # pairs are of the form `field name => error message`.
    #
    def validate_billing_info
      errors = {}

      if (posted['stripeToken'].nil? || posted['stripeToken'].empty?)
        errors['stripeToken'] = "Your card wasn't accepted."
      end

      errors
    end

  end

end; end;
