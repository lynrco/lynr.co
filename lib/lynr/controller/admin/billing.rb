require 'lynr/controller/admin'

module Lynr; module Controller;

  class AdminBilling < Lynr::Controller::Admin

    get  '/admin/:slug/billing', :get_billing
    post '/admin/:slug/billing', :post_billing

    def get_billing(req)
      return unauthorized unless authorized?(req)
      @subsection = 'billing'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @title = "Billing Information"
      @msg = req.session.delete('billing_flash_msg')
      # This card information should be stored locally. It is innocuous enough.
      # Or perhaps in memcache or something
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      @card = customer.active_card
      render 'admin/billing.erb'
    end

    def post_billing(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST
      @errors = validate_billing_info
      return render 'admin/billing.erb' if has_errors?
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      customer.card = posted['stripeToken']
      customer.save
      req.session['billing_flash_msg'] = "Card updated successfully."
      redirect "/admin/#{@dealership.id.to_s}/billing"
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

    def validate_billing_info
      errors = {}

      if (posted['stripeToken'].nil? || posted['stripeToken'].empty?)
        errors['stripeToken'] = "Your card wasn't accepted."
      end

      errors
    end

  end

end; end;
