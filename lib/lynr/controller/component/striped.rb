require './lib/lynr/controller'

module Lynr::Controller

  # # `Lynr::Controller::Stripe`
  #
  # The `Stripe` controller component encapsulates logic used when
  # interacting with customer and card objects on the Stripe service.
  #
  module Striped

    # ## `Striped#card_for(customer)`
    #
    # Retrieve the default_card from the list of cards attached to
    # `customer` which must be a `Stripe::Customer`.
    #
    def card_for(customer)
      customer.cards.find { |card| card.id == customer.default_card }
    end

    # ## `Striped#create_customer(identity)`
    #
    # Create `Stripe::Customer` instance from `identity` and `#posted`
    # data. This method reads the plan to attach to the customer from
    # `Lynr.config('app')`.
    #
    def create_customer(identity)
      customer = Stripe::Customer.create(
        card: posted['stripeToken'],
        plan: Lynr.config('app').fetch(:stripe, {}).plan,
        email: identity.email
      )
    end

    # ## `Striped#with_stripe_error_handlers(&thunk)`
    #
    # Execute `&thunk` and rescue `Stripe` errors if they are raised
    # passing the errors and an appropriate message to the
    # `#handle_stripe_error!` method.
    #
    def with_stripe_error_handlers(&thunk)
      thunk.call()
    rescue Stripe::CardError => sce
      handle_stripe_error!(sce, sce.message)
    rescue Stripe::InvalidRequestError => sire
      handle_stripe_error!(sire, "You might have submitted the form more than once.")
    rescue Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => sse
      msg = "Couldn't communicate with our card processor. We've been notified of the error."
      handle_stripe_error!(sse, msg)
    end

    # ## `Striped#handle_stripe_error!(err, message)`
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
      render template_path()
    end

  end

end
