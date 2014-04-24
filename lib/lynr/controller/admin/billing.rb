require 'stripe'

require './lib/lynr/controller'
require './lib/lynr/controller/admin'
require './lib/lynr/validator'

module Lynr; module Controller;

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

      require './lib/lynr/model/subscription'

      def cookie(req)
        value = URI.encode(req.cookies['_lynr']) if req.cookies['_lynr']
        live_domain = Lynr.config('app').fetch(:live_domain, 'www.lynr.co')
        # Thu, 01 May 2014 02:13:58 -0000; HttpOnly
        expires = (Time.now + 604800).utc.strftime('%a, %d %b %Y %H:%M:%S %z')
        "_lynr=#{value}; domain=#{live_domain}; path=/; expires=#{expires}; HttpOnly"
      end

      # ## `AdminBilling::Demo#get_account(req)`
      #
      # Handle GET request for the billing information page on the demo site.
      #
      def get_billing(req)
        render template_path()
      end

      def post_billing(req)
        with_stripe_error_handlers do
          dealership = dealership(req)
          stripe_config = Lynr.config('app').stripe
          identity = Lynr::Model::Identity.new(dealership.identity.email, posted['password'])
          customer = create_customer(identity)
          dealer = dealer_dao.save(dealership.set(
            'identity' => identity,
            'customer_id' => customer.id,
            'subscription' => Lynr::Model::Subscription.new(plan: stripe_config.plan, status: 'trialing'),
          ))
          # TODO: Need to set lynr.co cookie or this redirect will log me out
          live_domain = Lynr.config('app').fetch(:live_domain, 'www.lynr.co')
          expires = (Time.now + 604800).strftime('')
          redirect("https://#{live_domain}/admin/#{dealer.slug}/billing", 302, {
            'Set-Cookie' => cookie(req)
          })
        end
      end

      # ## `AdminBilling::Demo#template_path()`
      #
      # Define the path for the template to be rendered for GET requests
      # and POST requests with errors.
      #
      def template_path()
        'demo/admin/billing.erb'
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

end; end;
