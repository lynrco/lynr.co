require 'stripe'

require './lib/lynr/controller'
require './lib/lynr/controller/admin'
require './lib/lynr/validator'

module Lynr::Controller

  # # `Lynr::Controller::AdminBilling`
  #
  # Handles requests for the billing information page.
  #
  class AdminBilling < Lynr::Controller::Admin

    include Lynr::Controller::Striped
    include Lynr::Validator::Password

    get  '/admin/:slug/billing', :get_billing
    post '/admin/:slug/billing', :post_billing

    # ## `AdminBilling.new`
    #
    # Create a new instance of this controller and set up instance properties
    # needed for all request handlers.
    #
    # NOTE: The behavior of the `AdminBilling` varies based on the 'demo'
    # feature flag. When a new `AdminBilling` instance is created either
    # the `AdminBilling::Default` or `AdminBilling::Demo` modules are
    # used to extend the controller. These modules provide the
    # `#get_signup` and `#post_signup` methods through which requests
    # are routed in order to generate HTTP responses.
    #
    def initialize
      super
      @title = "Billing Information"
      @stripe_pub_key = Lynr.config('app').stripe.pub_key
      @subsection = 'billing'
      if Lynr.features.demo?
        self.send(:extend, AdminBilling::Demo)
      end
    end

    # ## `AdminBilling#before_POST(req)`
    #
    # Do data validation before processing a POST request. It doesn't need to be
    # in the POST handler.
    #
    def before_POST(req)
      super
      @errors = validate_billing_info
      render template_path() if has_errors?
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
      @card = card_for(customer)
      render template_path()
    end

    # ## `AdminBilling#post_account(req)`
    #
    # Handle POST request for the billing information page by inflating objects and
    # updating data.
    #
    def post_billing(req)
      with_stripe_error_handlers do
        customer = Stripe::Customer.retrieve(@dealership.customer_id)
        customer.card = posted['stripeToken']
        customer.save
        req.session['billing_flash_msg'] = "Card updated successfully."
        redirect "/admin/#{@dealership.slug}/billing"
      end
    end

    # ## `AdminBilling#template_path()`
    #
    # Define the path for the template to be rendered for GET requests
    # and POST requests with errors.
    #
    def template_path()
      'admin/billing.erb'
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

    # # `Lynr::Controller::AdminBilling::Demo`
    #
    # Method definitions to use when the demo 'feature' is on.
    #
    module Demo

      require './lib/lynr/events'
      require './lib/lynr/model/subscription'
      require './lib/lynr/model/token'
      require './lib/lynr/persist/dao'

      # ## `AdminBilling::Demo#get_billing(req)`
      #
      # Handle GET request for the billing information page on the demo site.
      #
      def get_billing(req)
        render template_path()
      end

      # ## `AdminBilling::Demo#post_billing(req)`
      #
      # Process a demo account into a live account and redirect the new
      # customer to the live site.
      #
      def post_billing(req)
        with_stripe_error_handlers do
          dealership = update_dealership(req)
          live_domain = Lynr.config('app').fetch(:live_domain, 'www.lynr.co')
          req.session.destroy
          Lynr::Events.emit(type: 'dealership.upgraded', dealership_id: dealership.id.to_s)
          redirect "https://#{live_domain}/signin/#{token(req).id}", 302
        end
      end

      # ## `AdminBilling::Demo#template_path()`
      #
      # Define the path for the template to be rendered for GET requests
      # and POST requests with errors.
      #
      def template_path() 'demo/admin/billing.erb' end

      def token(req)
        dao = Lynr::Persist::Dao.new
        dao.create(Lynr::Model::Token.new(
          'dealership' => dealership(req),
          'next' => "/admin/#{dealership(req).slug}",
        ))
      end

      # ## `AdminBilling::Demo#update_dealership(req)`
      #
      # Use the data in `req` to update the current dealership with new
      # customer and subscription information.
      #
      def update_dealership(req)
        identity = Lynr::Model::Identity.new(dealership(req).identity.email, posted['password'])
        customer = create_customer(identity)
        dealer_dao.save(dealership(req).set(
          'identity' => identity,
          'customer_id' => customer.id,
          'subscription' => Lynr::Model::Subscription.new(
            plan: Lynr.config('app').stripe.plan, status: 'trialing'
          ),
        ))
      end

      # ## `AdminBilling::Demo#validate_billing_info`
      #
      # Validate password information in addition to the stripeToken.
      #
      def validate_billing_info
        errors = super.merge(validate_required(posted, ['password']))
        errors['password'] ||= error_for_passwords(posted['password'], posted['password_confirm'])
        errors.delete_if { |k,v| v.nil? }
      end

    end

  end

end
