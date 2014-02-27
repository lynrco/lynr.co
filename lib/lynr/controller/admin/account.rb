require 'json'

require './lib/lynr'
require './lib/lynr/controller/admin'
require './lib/lynr/model/slug'
require './lib/lynr/queue/email_job'
require './lib/lynr/queue/stripe_update_job'
require './lib/lynr/validator'

module Lynr; module Controller;

  # # `Lynr::Controller::AdminAccount`
  #
  # Handles requests for the account information page.
  #
  class AdminAccount < Lynr::Controller::Admin

    include Lynr::Model
    include Lynr::Validator::Email

    get  '/admin/:slug/account', :get_account
    post '/admin/:slug/account', :post_account

    # ## `AdminAccount.new`
    #
    # Create a new instance of this controller and set up instance properties
    # needed for all request handlers.
    #
    def initialize
      super
      @subsection = 'account'
      @title = "Account Information"
      params = transloadit_params('account_template_id')
      @transloadit_params = params.to_json
      @transloadit_params_signature = transloadit_params_signature(params)
    end

    # ## `AdminAccount#before_GET(req)`
    #
    # Translate data from class @attributes into model instances.
    #
    def before_GET(req)
      super
      @posted = dealership(req).view.merge({ 'image' => dealership(req).image })
    end

    # ## `AdminAccount#before_POST(req)`
    #
    # Do data validation before processing a POST request. It doesn't need to be
    # in the POST handler.
    #
    def before_POST(req)
      super
      @errors = validate_account_info
      @posted['identity'] = Identity.new(posted['email'], dealership(req).identity.password)
      @posted['image'] = translate_image
      @posted['slug'] = slugify(posted['name']) if has_error?('slug') && posted['slug'].nil?
      render 'admin/account.erb' if has_errors?
    end

    # ## `AdminAccount#get_account(req)`
    #
    # Handle GET request for the account information page.
    #
    def get_account(req)
      @msg = connect_message(req)
      render 'admin/account.erb'
    end

    # ## `AdminAccount#post_account(req)`
    #
    # Handle POST request for the account information page by inflating objects and
    # updating data. Schedules background jobs to update information on payment
    # gateway if necessary.
    #
    def post_account(req)
      notify_by_email if email_changed?
      dealership = dealer_dao.save(dealership(req).set(posted))
      update_stripe(dealership) if email_changed? || name_changed?
      redirect "/admin/#{dealership(req).slug}/account"
    end

    # ## `AdminAccount#slugify(str)`
    #
    # Create a slug from `str`
    #
    def slugify(str)
      Slug.new(str)
    end

    protected

    # ## `AdminAccount#connect_message(req)`
    #
    # *Protected* Entry point for communicating with external account connection
    # paths. The account information page is the starting point for OAuth flows so
    # it is the logical place to display error or success messages related to those
    # external authentication flows. Reads parameters from `req` and returns a String
    # to be used in `@msg` for display on the page.
    #
    def connect_message(req)
      if !req.params[Lynr::Controller::Ebay::Helpers::PARAM].nil?
        Lynr::Controller::Ebay::Helpers.connect_message(req)
      elsif !req.params[Lynr::Controller::AdminAccountPassword::Helpers::PARAM].nil?
        Lynr::Controller::AdminAccountPassword::Helpers.connect_message(req)
      end
    end

    # ## `AdminAccount#email_changed?`
    #
    # *Protected* Check if the `email` on the current `@dealership` is different
    # from the `email` in the request. Used to determine if external updates need
    # to be made.
    #
    def email_changed?
      @dealership.identity.email != posted['email']
    end

    # ## `AdminAccount#name_changed?`
    #
    # *Protected* Check if the `name` on the current `@dealership` is different
    # from the `name` in the request. Used to determine if external updates need
    # to be made.
    #
    def name_changed?
      @dealership.name != posted['name']
    end

    # ## `AdminAccount#notify_by_email`
    #
    # *Protected* Add a background job to notify the old email address that the
    # email address has been changed.
    #
    def notify_by_email
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('email_updated', {
        to: @dealership.identity.email,
        subject: "Lynr.co email changed"
      }))
    end

    # ## `AdminAccount#translate_image`
    #
    # *Protected* Transform JSON data in a POST request into a
    # `Lynr::Model::SizedImage` or use the existing `@dealership` if no image
    # data exists in the POST.
    #
    def translate_image
      if !posted['image'].nil? && !posted['image'].empty?
        json = JSON.parse(posted['image'])
        Lynr::Model::SizedImage.inflate(json)
      else
        @dealership.image
      end
    end

    # ## `AdminAccount#update_stripe(dealership)`
    #
    # *Protected* Add a background job to notify the Stripe payment gateway
    # customer information has changed for `dealership`.
    #
    def update_stripe(dealership)
      Lynr.producer('stripe').publish(Lynr::Queue::StripeUpdateJob.new(dealership))
    end

    # ## `AdminAccount#validate_account_info`
    #
    # *Protected* Check `posted` data in the request is valid. Returns a `Hash`
    # with error information. `Hash` is empty if no errors, otherwise key value
    # pairs are of the form `field name => error message`.
    #
    def validate_account_info
      errors = validate_required(posted, ['email'])
      email = posted['email']
      slug = posted.fetch('slug', slugify(posted['name']))

      if (errors['email'].nil?)
        if (!is_valid_email?(email))
          errors['email'] = "Check your email address."
        elsif (email != @dealership.identity.email && dealer_dao.account_exists?(email))
          errors['email'] = "#{email} is already taken."
        end
      end

      if (slug != @dealership.slug && dealer_dao.slug_exists?(slug))
        errors['slug'] = "Dealership handle, <em>#{slug}</em>, is in use by someone else."
      end

      errors
    end

  end

end; end;
